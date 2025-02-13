//
//  Emitter.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import simd

public struct AEEmitterParams {
    public var position: AERange3
    public var scale: AERange
    public var velocity: AERange3
    public var lifeTime: AERange
    public var birthRate: Float

    public init(
        position: AERange3,
        scale: AERange,
        velocity: AERange3,
        lifeTime: AERange,
        birthRate: Float
    ) {
        self.position = position
        self.scale = scale
        self.velocity = velocity
        self.lifeTime = lifeTime
        self.birthRate = birthRate
    }
}

public struct AEEmitterUniforms {
    public var position: matrix_float3x2
    public var scale: SIMD2<Float>
    public var velocity: matrix_float3x2
    public var lifeTime: SIMD2<Float>
    public var aliveParticles: UInt32
    public var rngSeedX: Int32
    public var rngSeedY: Int32

    public init(
        position: matrix_float3x2, scale: SIMD2<Float>, velocity: matrix_float3x2,
        lifeTime: SIMD2<Float>, aliveParticles: UInt32, rngSeedX: Int32, rngSeedY: Int32
    ) {
        self.position = position
        self.scale = scale
        self.velocity = velocity
        self.lifeTime = lifeTime
        self.aliveParticles = aliveParticles
        self.rngSeedX = rngSeedX
        self.rngSeedY = rngSeedY
    }
}
