//
//  ParticleSystem.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 18.01.2024.
//

import Foundation
import Metal

class AtomicSwap {
    private var mutex = pthread_mutex_t()
    private var index: Int = 0

    init() {
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    func swap() {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        index = (index + 1) % 2
    }

    func get() -> Int {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        return index
    }
}

open class AEParticlesAsset: AEAsset {
    public init() {
        self.emitShader = AEShader(named: "emit_particles", isInternal: true)
        self.updateShader = AEShader(named: "update_particles", isInternal: true)
        self.sortShader = AEShader(named: "sort_particles", isInternal: true)
    }

    public init(emitShader: AEShader, updateShader: AEShader, sortShader: AEShader) {
        self.emitShader = emitShader
        self.updateShader = updateShader
        self.sortShader = sortShader
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
    private var renderTarget: AtomicSwap = .init()
    private var aliveCounterBuffer: MTLBuffer!

    private var aliveCount: UInt32 = 0
    private var deadCount: UInt32 {
        UInt32(maxCount) - aliveCount
    }

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
                length: MemoryLayout<Particle>.stride * maxCount
            )!,
            AERenderer.device.makeBuffer(
                length: MemoryLayout<Particle>.stride * maxCount
            )!,
        ]
        renderBuffers = [
            AERenderer.device.makeBuffer(
                length: MemoryLayout<Particle>.stride * maxCount
            )!,
            AERenderer.device.makeBuffer(
                length: MemoryLayout<Particle>.stride * maxCount
            )!,
        ]
        aliveCounterBuffer = AERenderer.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride
        )
    }

    public override func performUpdate(deltaTime: Float) {
        let aliveParticlesPtr = self.aliveCounterBuffer.contents().bindMemory(
            to: UInt32.self, capacity: 1)
        self.aliveCount = min(aliveParticlesPtr.pointee, UInt32(self.maxCount))

        let commandBuffer = AERenderer.commandQueue.makeCommandBuffer()!

        self.birthAcc += deltaTime * Float(emitterParams.birthRate)
        let emitCount = max(0, min(UInt32(self.birthAcc), deadCount))

        if emitCount > 0 {
            emitParticles(count: emitCount, commandBuffer: commandBuffer)
            self.birthAcc -= Float(emitCount)
        }

        if aliveCount > 0 {
            updateParticles(commandBuffer: commandBuffer)
        }

        clearParticles(commandBuffer: commandBuffer)

        sortParticles(commandBuffer: commandBuffer)

        copyParticles(commandBuffer: commandBuffer)

        commandBuffer.addCompletedHandler { _ in
            self.updateBuffers.swapAt(0, 1)
            self.renderTarget.swap()
        }

        commandBuffer.commit()
    }

    private func emitParticles(count: UInt32, commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = ComputeStates.makeComputeState(for: particleSystemAsset.emitShader)

        var emitterUniforms = EmitterUniforms(
            position: emitterParams.position.simd,
            scale: emitterParams.scale.simd,
            velocity: emitterParams.velocity.simd,
            lifeTime: emitterParams.lifeTime.simd,
            aliveParticles: aliveCount,
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
            &emitterUniforms, length: MemoryLayout<EmitterUniforms>.stride, index: 1)
        commandEncoder.setBytes(
            &modelUniforms, length: MemoryLayout<AEModelUniforms>.stride, index: 2)
        commandEncoder.dispatchThreads(
            threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup
        )

        commandEncoder.endEncoding()
    }

    private func updateParticles(commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = ComputeStates.makeComputeState(for: particleSystemAsset.updateShader)

        let width = state.threadExecutionWidth
        let threadsPerThreadGroup = MTLSize(width: width, height: 1, depth: 1)

        let threadsPerGrid = MTLSize(width: Int(aliveCount), height: 1, depth: 1)
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(updateBuffers[0], offset: 0, index: 0)
        commandEncoder.setBytes(
            &AERenderer.currentScene!.uniforms, length: MemoryLayout<AESceneUniforms>.stride,
            index: 1
        )
        commandEncoder.dispatchThreads(
            threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup
        )

        commandEncoder.endEncoding()
    }

    private func sortParticles(commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = ComputeStates.makeComputeState(for: particleSystemAsset.sortShader)

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
    }

    private func clearParticles(commandBuffer: MTLCommandBuffer) {
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!

        blitEncoder.fill(
            buffer: updateBuffers[1],
            range: 0..<MemoryLayout<Particle>.stride * maxCount,
            value: 0
        )
        blitEncoder.endEncoding()
    }

    private func copyParticles(commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeBlitCommandEncoder()!

        commandEncoder.copy(
            from: updateBuffers[0],
            sourceOffset: 0,
            to: renderBuffers[0],
            destinationOffset: 0,
            size: MemoryLayout<Particle>.stride * maxCount
        )
        commandEncoder.endEncoding()
    }

    public override func performRender(commandEncoder: MTLRenderCommandEncoder) {
        if aliveCount == 0 {
            return
        }

        let state = self.particleParams.material.load()

        commandEncoder.setRenderPipelineState(state)
        commandEncoder.setDepthStencilState(depthStencilState)

        let buffer = self.particleParams.mesh.load()

        commandEncoder.setVertexBuffer(buffer.vertices, offset: 0, index: 0)
        commandEncoder.setVertexBytes(
            &AERenderer.currentScene!.uniforms, length: MemoryLayout<AESceneUniforms>.stride,
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
            instanceCount: Int(aliveCount)
        )
    }
}
