//
//  ParticleMaterial.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import Metal

open class AEParticleMaterial: AEUnlitMaterial {
    open override func getVertexShader() -> AEShader {
        AEShader(named: "particles_vertex_shader")
    }

    open override func getFragmentShader() -> AEShader {
        AEShader(named: "particles_fragment_shader")
    }

    open override func makeRenderPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.vertexFunction = getVertexShader().load()
        pipelineDescriptor.fragmentFunction = getFragmentShader().load()
        pipelineDescriptor.vertexDescriptor = AEVertex.descriptor
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
