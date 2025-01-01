//
//  Mesh.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal
import simd

struct AEMeshBuffer {
    var vertices: MTLBuffer
    var indices: MTLBuffer
    var indexCount: Int
}

protocol AEMesh: AEAsset where AssetType == AEMeshBuffer {
    
}
