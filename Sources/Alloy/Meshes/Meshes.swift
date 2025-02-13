//
//  Meshes.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 27.01.2024.
//

import Foundation

public class AEMeshesAsset: AEAsset {
    private init() {}

    static let shared: AEMeshesAsset = .init()

    private var assets: [any AEAsset] = [
        AEMeshes.plane
    ]

    func load() {
        _ = assets.map { $0.load() }
    }
}

public class AEMeshes {
    private init() {}

    static let plane: AEPlane = {
        AEPlane()
    }()
}
