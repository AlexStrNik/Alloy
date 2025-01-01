//
//  MeshObject.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

class AEMeshObject: AEGameObject {
    var mesh: any AEMesh
    var material: any AEMaterial
    
    init(mesh: any AEMesh, material: any AEMaterial) {
        self.mesh = mesh
        self.material = material
    }
    
    override func performRender(commandEncoder: MTLRenderCommandEncoder) {
        let state = self.material.load()
        
        commandEncoder.setRenderPipelineState(state)
        commandEncoder.setDepthStencilState(DepthStencils.makeLessDepthStencil())
        
        let buffer = self.mesh.load()
        
        var modelUniforms = ModelUniforms(
            modelMatrix: self.transform.matrix
        )
        
        commandEncoder.setVertexBuffer(buffer.vertices, offset: 0, index: 0)
        commandEncoder.setVertexBytes(
            &AERenderer.currentScene!.uniforms, length: MemoryLayout<SceneUniforms>.stride, index: 1
        )
        commandEncoder.setVertexBytes(&modelUniforms, length: MemoryLayout<ModelUniforms>.stride, index: 2)
        
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
