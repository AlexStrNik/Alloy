//
//  Emitter.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import simd

public struct AEEmitterParams {
    public var position: Range3
    public var scale: Range
    public var velocity: Range3
    public var lifeTime: Range
    public var birthRate: Float
}

public struct EmitterUniforms {
    public var position: matrix_float3x2
    public var scale: SIMD2<Float>
    public var velocity: matrix_float3x2
    public var lifeTime: SIMD2<Float>
    public var aliveParticles: UInt32
    public var rngSeedX: Int32
    public var rngSeedY: Int32
}
