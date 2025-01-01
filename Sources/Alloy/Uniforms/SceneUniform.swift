//
//  SceneUniform.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import simd

struct SceneUniforms {
    var iTime: Float
    var deltaTime: Float
    var viewMatrix: float4x4
    var projectionMatrix: float4x4
}
