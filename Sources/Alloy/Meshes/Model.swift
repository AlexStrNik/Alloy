//
//  Model.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 24.01.2024.
//

import Foundation
import MetalKit
import ModelIO

open class AEModelMesh: AEMesh {
    var url: URL

    init(url: URL) {
        self.url = url
    }

    private var meshBuffer: AEMeshBuffer?

    public func load() -> AEMeshBuffer {
        if let meshBuffer = self.meshBuffer {
            return meshBuffer
        }

        let allocator = MTKMeshBufferAllocator(device: AERenderer.device)
        let asset = MDLAsset(
            url: url,
            vertexDescriptor: AEModelMesh.vertexDescriptor,
            bufferAllocator: allocator
        )

        let mesh = (asset.childObjects(of: MDLMesh.self) as! [MDLMesh]).first!
        mesh.vertexDescriptor = AEModelMesh.vertexDescriptor

        let mtkMesh = try! MTKMesh(mesh: mesh, device: AERenderer.device)

        let submesh = mtkMesh.submeshes.first!

        self.meshBuffer = AEMeshBuffer(
            vertices: mtkMesh.vertexBuffers[0].buffer,
            indices: submesh.indexBuffer.buffer,
            indexCount: submesh.indexCount
        )

        return meshBuffer!
    }

    private static var vertexDescriptor: MDLVertexDescriptor {
        let descriptor = MTKModelIOVertexDescriptorFromMetal(AEVertex.descriptor)
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate

        return descriptor
    }
}
