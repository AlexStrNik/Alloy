//
//  Material.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

public protocol AEMaterial: AEAsset where AssetType == MTLRenderPipelineState {
    func getVertexShader() -> AEShader
    func getFragmentShader() -> AEShader

    func makeRenderPipelineDescriptor() -> MTLRenderPipelineDescriptor

    func encode(to commandEncoder: MTLRenderCommandEncoder)
}
