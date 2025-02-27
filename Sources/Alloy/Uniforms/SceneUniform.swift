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

    public init(iTime: Float, deltaTime: Float, viewMatrix: float4x4, projectionMatrix: float4x4) {
        self.iTime = iTime
        self.deltaTime = deltaTime
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
    }
}
