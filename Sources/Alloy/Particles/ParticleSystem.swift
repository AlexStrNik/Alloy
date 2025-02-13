//
//  ParticleSystem.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 18.01.2024.
//

import Foundation
import Metal

open class AEParticlesAsset: AEAsset {
    private init() {}

    static let shared: AEParticlesAsset = .init()

    let emitShader: AEShader = AEShader(named: "emit_particles", isInternal: true)

    let updateShader: AEShader = AEShader(named: "update_particles", isInternal: true)

    let sortShader: AEShader = AEShader(named: "sort_particles", isInternal: true)

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

    private var maxCount: Int

    private var updateBuffers: [MTLBuffer] = []
    private var renderBuffers: [MTLBuffer] = []
    private var aliveCounterBuffer: MTLBuffer!

    private var aliveCount: UInt32 = 0
    private var deadCount: UInt32 {
        UInt32(maxCount) - aliveCount
    }

    private var birthAcc: Float = 0

    public init(
        maxCount: Int,
        emitterParams: AEEmitterParams,
        particleParams: AEParticleParams
    ) {
        self.maxCount = maxCount
        self.emitterParams = emitterParams
        self.particleParams = particleParams
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
        }

        commandBuffer.commit()
    }

    private func emitParticles(count: UInt32, commandBuffer: MTLCommandBuffer) {
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        let state = ComputeStates.makeComputeState(for: AEParticlesAsset.shared.emitShader)

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
        let state = ComputeStates.makeComputeState(for: AEParticlesAsset.shared.updateShader)

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
        let state = ComputeStates.makeComputeState(for: AEParticlesAsset.shared.sortShader)

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
        commandEncoder.setDepthStencilState(AEDepthStencils.makeLessDepthStencil())

        let buffer = self.particleParams.mesh.load()

        commandEncoder.setVertexBuffer(buffer.vertices, offset: 0, index: 0)
        commandEncoder.setVertexBytes(
            &AERenderer.currentScene!.uniforms, length: MemoryLayout<AESceneUniforms>.stride,
            index: 1
        )
        renderBuffers.swapAt(0, 1)
        commandEncoder.setVertexBuffer(renderBuffers[1], offset: 0, index: 2)
        commandEncoder.setFragmentBuffer(renderBuffers[1], offset: 0, index: 1)
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
