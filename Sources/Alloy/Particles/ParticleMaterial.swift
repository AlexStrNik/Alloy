//
//  ParticleMaterial.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import Metal

class AEParticleMaterial: AEUnlitMaterial {
    override func getVertexShader() -> AEShader {
        AEShader(named: "particles_vertex_shader")
    }

    override func getFragmentShader() -> AEShader {
        AEShader(named: "particles_fragment_shader")
    }
    
    override func makeRenderPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexFunction = getVertexShader().load()
        pipelineDescriptor.fragmentFunction = getFragmentShader().load()
        pipelineDescriptor.vertexDescriptor = Vertex.descriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = AERenderer.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = AERenderer.depthStencilPixelFormat
        
        return pipelineDescriptor
    }
}

extension AEMaterial where Self == AEParticleMaterial {
    static var particle: AEParticleMaterial {
        .init()
    }
}
