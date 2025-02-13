//
//  Asset.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 27.01.2024.
//

import Foundation

public protocol AEAsset<AssetType> {
    associatedtype AssetType

    func load() -> AssetType
}
