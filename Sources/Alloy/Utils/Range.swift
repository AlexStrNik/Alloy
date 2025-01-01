//
//  Range.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import simd

struct Range {
    var min: Float
    var max: Float
    
    init(min: Float, max: Float) {
        self.min = min
        self.max = max
    }
    
    init(_ fixed: Float) {
        self.min = fixed
        self.max = fixed
    }
    
    var simd: SIMD2<Float> {
        SIMD2(min, max)
    }
}

struct Range3 {
    var x: Range
    var y: Range
    var z: Range
    
    init(x: Range, y: Range, z: Range) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(min: Float, max: Float) {
        self.x = .init(min: min, max: max)
        self.y = .init(min: min, max: max)
        self.z = .init(min: min, max: max)
    }
    
    var simd: matrix_float3x2 {
        .init(
            x.simd,
            y.simd,
            z.simd
        )
    }
}
