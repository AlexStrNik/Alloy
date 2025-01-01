//
//  Math.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import simd

extension float4x4 {
    init(scaleBy axis: SIMD3<Float>) {
        self.init(
            .init(axis.x, 0, 0, 0),
            .init(0, axis.y, 0, 0),
            .init(0, 0, axis.z, 0),
            .init(0, 0, 0, 1)
        )
    }
    
    init(rotationAbout axis: SIMD3<Float>, by angleRadians: Float) {
        let x = axis.x, y = axis.y, z = axis.z
        let c = cosf(angleRadians)
        let s = sinf(angleRadians)
        let t = 1 - c
        
        self.init(
            .init(t * x * x + c, t * x * y + z * s, t * x * z - y * s, 0),
            .init(t * x * y - z * s, t * y * y + c, t * y * z + x * s, 0),
            .init(t * x * z + y * s, t * y * z - x * s, t * z * z + c, 0),
            .init(0, 0, 0, 1)
        )
    }
    
    init(translationBy t: SIMD3<Float>) {
        self.init(
            .init(1, 0, 0, 0),
            .init(0, 1, 0, 0),
            .init(0, 0, 1, 0),
            .init(t, 1)
        )
    }
}

extension SIMD3<Float> {
    static var xAxis: SIMD3<Float> = .init(1, 0, 0)
    static var yAxis: SIMD3<Float> = .init(0, 1, 0)
    static var zAxis: SIMD3<Float> = .init(0, 1, 0)
}

extension SIMD4<Float> {
    var xyz: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}
