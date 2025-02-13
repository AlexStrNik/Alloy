//
//  Texture.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 12.01.2024.
//

import Foundation
import Metal
import MetalKit

public class AETexture: AEAsset {
    let url: URL

    private var texture: MTLTexture?

    init(url: URL) {
        self.url = url
    }

    func load() -> MTLTexture {
        if let texture = texture {
            return texture
        }

        self.texture = try! AERenderer.textureLoader.newTexture(
            URL: url,
            options: [
                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                .textureStorageMode: MTLStorageMode.shared.rawValue,
                .SRGB: false,
            ]
        )

        return texture!
    }
}
