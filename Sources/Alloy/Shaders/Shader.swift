//
//  Shader.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

public class AEShader: AEAsset {
    let name: String

    private var function: MTLFunction?

    init(named: String) {
        self.name = named
    }

    func load() -> MTLFunction {
        if let function = function {
            return function
        }

        self.function = AERenderer.library.makeFunction(name: name)!

        return function!
    }
}
