//
//  Range.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import simd

public struct Range {
    public var min: Float
    public var max: Float

    public init(min: Float, max: Float) {
        self.min = min
        self.max = max
    }

    public init(_ fixed: Float) {
        self.min = fixed
        self.max = fixed
    }

    var simd: SIMD2<Float> {
        SIMD2(min, max)
    }
}

public struct Range3 {
    public var x: Range
    public var y: Range
    public var z: Range

    public init(x: Range, y: Range, z: Range) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(min: Float, max: Float) {
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
