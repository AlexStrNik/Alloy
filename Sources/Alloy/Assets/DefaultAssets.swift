//
//  DefaultAssets.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 27.01.2024.
//

import Foundation

class AEDefaultAssets: AEAsset {
    static let shared: AEDefaultAssets = .init()
    
    private var assets: [any AEAsset] = [
        AEParticlesAsset.shared,
        AEMeshesAsset.shared
    ]
    
    private init() {}
    
    func load() -> Void {
        _ = self.assets.map { $0.load() }
    }
}
