//
//  Vertex.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

public struct Vertex {
    var position: SIMD3<Float>
    var normal: SIMD3<Float>
    var uv: SIMD2<Float>

    static var descriptor: MTLVertexDescriptor = {
        var descriptor = MTLVertexDescriptor()

        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0

        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride

        descriptor.attributes[2].format = .float2
        descriptor.attributes[2].bufferIndex = 0
        descriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride * 2

        descriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        return descriptor
    }()
}
