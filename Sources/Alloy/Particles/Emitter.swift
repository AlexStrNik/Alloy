//
//  Emitter.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import simd

struct AEEmitterParams {
    var position: Range3
    var scale: Range
    var velocity: Range3
    var lifeTime: Range
    var birthRate: Float
}

struct EmitterUniforms {
    var position: matrix_float3x2
    var scale: SIMD2<Float>
    var velocity: matrix_float3x2
    var lifeTime: SIMD2<Float>
    var aliveParticles: UInt32
    var rngSeedX: Int32
    var rngSeedY: Int32
}
