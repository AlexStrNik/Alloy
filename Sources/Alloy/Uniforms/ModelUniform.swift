//
//  ModelUniform.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import simd

public struct AEModelUniforms {
    public var modelMatrix: float4x4

    public init(modelMatrix: float4x4) {
        self.modelMatrix = modelMatrix
    }
}
