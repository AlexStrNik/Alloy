//
//  Particle.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 18.01.2024.
//

import Foundation

struct Particle {
    var position: SIMD3<Float>
    var velocity: SIMD3<Float>
    var scale: Float
    var age: Float
}

struct AEParticleParams {
    var mesh: any AEMesh
    var material: any AEMaterial
}
