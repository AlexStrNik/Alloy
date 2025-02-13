//
//  Shader.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

open class AEShader: AEAsset {
    let name: String
    let isInternal: Bool

    private var function: MTLFunction?

    public init(named: String, isInternal: Bool = false) {
        self.name = named
        self.isInternal = isInternal
    }

    public func load() -> MTLFunction {
        if let function = function {
            return function
        }

        if isInternal {
            self.function = AERenderer.internalLibrary.makeFunction(name: name)!
        } else {
            self.function = AERenderer.library.makeFunction(name: name)!
        }

        return function!
    }
}
