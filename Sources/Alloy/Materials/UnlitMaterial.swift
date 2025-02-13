//
//  UnlitMaterial.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

open class AEUnlitMaterial: AEMaterial {
    private var state: MTLRenderPipelineState?

    public func getVertexShader() -> AEShader {
        AEShader(named: "unlit_vertex_shader")
    }

    public func getFragmentShader() -> AEShader {
        AEShader(named: "unlit_fragment_shader")
    }

    public func makeRenderPipelineDescriptor() -> MTLRenderPipelineDescriptor {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.vertexFunction = getVertexShader().load()
        pipelineDescriptor.fragmentFunction = getFragmentShader().load()
        pipelineDescriptor.vertexDescriptor = Vertex.descriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = AERenderer.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = AERenderer.depthStencilPixelFormat

        return pipelineDescriptor
    }

    public func encode(to commandEncoder: MTLRenderCommandEncoder) {

    }

    public func load() -> MTLRenderPipelineState {
        if let state = self.state {
            return state
        }

        self.state = try! AERenderer.device.makeRenderPipelineState(
            descriptor: self.makeRenderPipelineDescriptor()
        )

        return state!
    }
}

extension AEMaterial where Self == AEUnlitMaterial {
    static var unlit: AEUnlitMaterial {
        .init()
    }
}
