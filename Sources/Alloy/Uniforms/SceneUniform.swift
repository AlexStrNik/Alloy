//
//  SceneUniform.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import simd

public struct AESceneUniforms {
    public var iTime: Float
    public var deltaTime: Float
    public var viewMatrix: float4x4
    public var projectionMatrix: float4x4
}
