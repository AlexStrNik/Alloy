//
//  Mesh.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal
import simd

public struct AEMeshBuffer {
    public var vertices: MTLBuffer
    public var indices: MTLBuffer
    public var indexCount: Int

    public init(vertices: MTLBuffer, indices: MTLBuffer, indexCount: Int) {
        self.vertices = vertices
        self.indices = indices
        self.indexCount = indexCount
    }
}

public protocol AEMesh: AEAsset where AssetType == AEMeshBuffer {

}
