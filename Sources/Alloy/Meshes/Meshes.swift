//
//  Meshes.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 27.01.2024.
//

import Foundation

class AEMeshesAsset: AEAsset {
    private init() {}
    
    static let shared: AEMeshesAsset = .init()
    
    private var assets: [any AEAsset] = [
       AEMeshes.plane
    ]
    
    func load() -> Void {
        _ = assets.map { $0.load() }
    }
}

class AEMeshes {
    private init() {}
    
    static let plane: AEPlane = {
        AEPlane()
    }()
}
