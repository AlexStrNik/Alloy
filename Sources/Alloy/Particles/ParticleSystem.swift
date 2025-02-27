//
//  ParticleSystem.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 18.01.2024.
//

import Foundation
import Metal

class Atomic<T> {
    private var mutex = pthread_mutex_t()
    private var value: T

    init(value: T) {
        pthread_mutex_init(&mutex, nil)
        self.value = value
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    func set(_ value: T) {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        self.value = value
    }

    func get() -> T {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        return value
    }
}

extension Atomic where T == Bool {
    func toggleTrue() -> Bool {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        let value = self.value
        if value {
            self.value = false
            return true
        }
        return false
    }
}

extension Atomic where T == Int {
    func modInc(_ maxCount: Int) {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        self.value = (self.value + 1) % maxCount
    }
}

open class AEParticlesAsset: AEAsset {
    public init(
        emitShader: AEShader? = nil,
        updateShader: AEShader? = nil,
        sortShader: AEShader? = nil
    ) {
        self.emitShader = emitShader ?? AEShader(named: "emit_particles", isInternal: true)
        self.updateShader = updateShader ?? AEShader(named: "update_particles", isInternal: true)
        self.sortShader = sortShader ?? AEShader(named: "sort_particles", isInternal: true)
    }

    public static let `default`: AEParticlesAsset = .init()

    public let emitShader: AEShader
    public let updateShader: AEShader
    public let sortShader: AEShader

    private var assets: [any AEAsset] {
        [emitShader, updateShader, sortShader]
    }

    public func load() {
        _ = self.assets.map { $0.load() }
    }
}

open class AEParticleSystem: AEGameObject {
    public var emitterParams: AEEmitterParams
    public var particleParams: AEParticleParams
    public var particleSystemAsset: AEParticlesAsset
    public var depthStencilState: MTLDepthStencilState?

    private var maxCount: Int

    private var updateBuffers: [MTLBuffer] = []
    private var renderBuffers: [MTLBuffer] = []
    private var renderTarget: Atomic<Int> = .init(value: 0)
    private var aliveCounterBuffer: MTLBuffer!

    private var aliveCount: Atomic<UInt32> = .init(value: 0)
    private var deadCount: UInt32 {
        UInt32(maxCount) - aliveCount.get()
    }
    private var updateCompleted: Atomic<Bool> = .init(value: true)

    private var birthAcc: Float = 0

    public init(
        maxCount: Int,
        emitterParams: AEEmitterParams,
        particleParams: AEParticleParams,
        particleSystemAsset: AEParticlesAsset = AEParticlesAsset.default,
        depthStencilState: MTLDepthStencilState? = nil
    ) {
        self.maxCount = maxCount
        self.emitterParams = emitterParams
        self.particleParams = particleParams
        self.particleSystemAsset = particleSystemAsset
        self.depthStencilState = depthStencilState ?? AEDepthStencils.makeLessDepthStencil()
    }

    public override func initialize() {
        updateBuffers = [
            AERenderer.device.makeBuffer(
                length: MemoryLayout<AEParticle>.stride * maxCount,
                options: .storageModePrivate
            )!,
            AERenderer.device.makeBuffer(
                length: MemoryLayout<AEParticle>.stride * maxCount,
                options: .storageModePrivate
            )!,
        ]
        renderBuffers = [
            AERenderer.device.makeBuffer(
                length: MemoryLayout<AEParticle>.stride * maxCount,
                options: .storageModePrivate
            )!,
            AERenderer.device.makeBuffer(
                length: MemoryLayout<AEParticle>.stride * maxCount,
                options: .storageModePrivate
            )!,
        ]
        aliveCounterBuffer = AERenderer.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride,
            options: .storageModeManaged
        )
    }

    public override func performUpdate(deltaTime: Float) {
        if !updateCompleted.toggleTrue() {
            return
        }

        let aliveParticlesPtr = self.aliveCounterBuffer.contents().assumingMemoryBound(
            to: UInt32.self
        )
        self.aliveCount.set(
            min(aliveParticlesPtr.pointee, UInt32(self.maxCount))
        )

        let commandBuffer = AERenderer.commandQueue.makeCommandBuffer()!

        self.birthAcc += deltaTime * Float(emitterParams.birthRate)
        let emitCount = max(0, min(UInt32(self.birthAcc), deadCount))
        self.birthAcc -= floor(self.birthAcc)

        if emitCount > 0 {
            emitParticles(count: emitCount, commandBuffer: commandBuffer)
        }

        if aliveCount.get() > 0 {
            updateParticles(commandBuffer: commandBuffer)
        }

        clearParticles(commandBuffer: commandBuffer)

        sortParticles(commandBuffer: commandBuffer)

        copyParticles(commandBuffer: commandBuffer)

        commandBuffer.addCompletedHandler { _ in
            self.updateBuffers.swapAt(0, 1)
            self.renderTarget.modInc(2)
            self.updateCompleted.set(true)
        }

        commandBuffer.commit()
    }

    private func emitParticles(count: UInt32, commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = AEComputeStates.makeComputeState(
            for: particleSystemAsset.emitShader
        )

        var emitterUniforms = AEEmitterUniforms(
            position: emitterParams.position.simd,
            scale: emitterParams.scale.simd,
            velocity: emitterParams.velocity.simd,
            lifeTime: emitterParams.lifeTime.simd,
            aliveParticles: aliveCount.get(),
            rngSeedX: .random(in: 0...100),
            rngSeedY: .random(in: 0...100)
        )

        var modelUniforms = AEModelUniforms(
            modelMatrix: self.transform.matrix
        )

        let width = state.threadExecutionWidth
        let threadsPerThreadGroup = MTLSize(width: width, height: 1, depth: 1)

        let threadsPerGrid = MTLSize(width: Int(count), height: 1, depth: 1)
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(updateBuffers[0], offset: 0, index: 0)
        commandEncoder.setBytes(
            &emitterUniforms,
            length: MemoryLayout<AEEmitterUniforms>.stride,
            index: 1
        )
        commandEncoder.setBytes(
            &modelUniforms,
            length: MemoryLayout<AEModelUniforms>.stride,
            index: 2
        )
        commandEncoder.dispatchThreads(
            threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup
        )

        commandEncoder.endEncoding()
    }

    private func updateParticles(commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = AEComputeStates.makeComputeState(
            for: particleSystemAsset.updateShader
        )

        let width = state.threadExecutionWidth
        let threadsPerThreadGroup = MTLSize(width: width, height: 1, depth: 1)

        let threadsPerGrid = MTLSize(width: maxCount, height: 1, depth: 1)
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(updateBuffers[0], offset: 0, index: 0)
        commandEncoder.setBytes(
            &AERenderer.currentScene!.uniforms,
            length: MemoryLayout<AESceneUniforms>.stride,
            index: 1
        )
        commandEncoder.dispatchThreads(
            threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup
        )

        commandEncoder.endEncoding()
    }

    private func sortParticles(commandBuffer: MTLCommandBuffer) {
        let resetEncoder = commandBuffer.makeBlitCommandEncoder()!
        resetEncoder.fill(
            buffer: aliveCounterBuffer,
            range: 0..<MemoryLayout<UInt32>.stride,
            value: 0
        )
        resetEncoder.endEncoding()

        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = AEComputeStates.makeComputeState(
            for: particleSystemAsset.sortShader
        )

        let width = state.threadExecutionWidth
        let threadsPerThreadGroup = MTLSize(width: width, height: 1, depth: 1)

        let threadsPerGrid = MTLSize(width: maxCount, height: 1, depth: 1)
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(updateBuffers[0], offset: 0, index: 0)
        commandEncoder.setBuffer(updateBuffers[1], offset: 0, index: 1)
        commandEncoder.setBuffer(aliveCounterBuffer, offset: 0, index: 2)
        commandEncoder.dispatchThreads(
            threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup
        )

        commandEncoder.endEncoding()

        let syncEncoder = commandBuffer.makeBlitCommandEncoder()!
        syncEncoder.synchronize(resource: aliveCounterBuffer)
        syncEncoder.endEncoding()
    }

    private func clearParticles(commandBuffer: MTLCommandBuffer) {
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!

        blitEncoder.fill(
            buffer: updateBuffers[1],
            range: 0..<MemoryLayout<AEParticle>.stride * maxCount,
            value: 0
        )
        blitEncoder.endEncoding()
    }

    private func copyParticles(commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeBlitCommandEncoder()!

        commandEncoder.copy(
            from: updateBuffers[0],
            sourceOffset: 0,
            to: renderBuffers[(renderTarget.get() + 1) % 2],
            destinationOffset: 0,
            size: MemoryLayout<AEParticle>.stride * maxCount
        )
        commandEncoder.endEncoding()
    }

    public override func performRender(commandEncoder: MTLRenderCommandEncoder) {
        if aliveCount.get() == 0 {
            return
        }

        let state = self.particleParams.material.load()

        commandEncoder.setRenderPipelineState(state)
        commandEncoder.setDepthStencilState(depthStencilState)

        let buffer = self.particleParams.mesh.load()

        commandEncoder.setVertexBuffer(buffer.vertices, offset: 0, index: 0)
        commandEncoder.setVertexBytes(
            &AERenderer.currentScene!.uniforms,
            length: MemoryLayout<AESceneUniforms>.stride,
            index: 1
        )

        let renderBuffer = renderBuffers[renderTarget.get()]

        commandEncoder.setVertexBuffer(renderBuffer, offset: 0, index: 2)
        commandEncoder.setFragmentBuffer(renderBuffer, offset: 0, index: 1)
        self.particleParams.material.encode(to: commandEncoder)

        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: buffer.indexCount,
            indexType: .uint32,
            indexBuffer: buffer.indices,
            indexBufferOffset: 0,
            instanceCount: Int(aliveCount.get())
        )
    }
}
