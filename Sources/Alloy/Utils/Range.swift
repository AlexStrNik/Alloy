//
//  Range.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import simd

public struct AERange {
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

    public var simd: SIMD2<Float> {
        SIMD2(min, max)
    }
}

public struct AERange3 {
    public var x: AERange
    public var y: AERange
    public var z: AERange

    public init(x: AERange, y: AERange, z: AERange) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(min: Float, max: Float) {
        self.x = .init(min: min, max: max)
        self.y = .init(min: min, max: max)
        self.z = .init(min: min, max: max)
    }

    public var simd: matrix_float3x2 {
        .init(
            x.simd,
            y.simd,
            z.simd
        )
    }
}
