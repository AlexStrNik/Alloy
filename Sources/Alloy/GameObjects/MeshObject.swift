//
//  MeshObject.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

open class AEMeshObject: AEGameObject {
    public var mesh: any AEMesh
    public var material: any AEMaterial

    public init(mesh: any AEMesh, material: any AEMaterial) {
        self.mesh = mesh
        self.material = material
    }

    open override func performRender(commandEncoder: MTLRenderCommandEncoder) {
        let state = self.material.load()

        commandEncoder.setRenderPipelineState(state)
        commandEncoder.setDepthStencilState(AEDepthStencils.makeLessDepthStencil())

        let buffer = self.mesh.load()

        var modelUniforms = AEModelUniforms(
            modelMatrix: self.transform.matrix
        )

        commandEncoder.setVertexBuffer(buffer.vertices, offset: 0, index: 0)
        commandEncoder.setVertexBytes(
            &AERenderer.currentScene!.uniforms, length: MemoryLayout<AESceneUniforms>.stride,
            index: 1
        )
        commandEncoder.setVertexBytes(
            &modelUniforms, length: MemoryLayout<AEModelUniforms>.stride, index: 2)

        material.encode(to: commandEncoder)

        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: buffer.indexCount,
            indexType: .uint32,
            indexBuffer: buffer.indices,
            indexBufferOffset: 0
        )
    }
}
