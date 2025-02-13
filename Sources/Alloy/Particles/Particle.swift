//
//  Particle.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 18.01.2024.
//

import Foundation

public struct AEParticle {
    public var position: SIMD3<Float>
    public var velocity: SIMD3<Float>
    public var scale: Float
    public var age: Float

    public init(position: SIMD3<Float>, velocity: SIMD3<Float>, scale: Float, age: Float) {
        self.position = position
        self.velocity = velocity
        self.scale = scale
        self.age = age
    }
}

public struct AEParticleParams {
    public var mesh: any AEMesh
    public var material: any AEMaterial

    public init(mesh: any AEMesh, material: any AEMaterial) {
        self.mesh = mesh
        self.material = material
    }
}
