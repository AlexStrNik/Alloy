//
//  Transform.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import simd

public class AETransform {
    var parent: AETransform?

    var position: SIMD3<Float> = .zero {
        didSet {
            updateMatrix()
        }
    }

    var rotation: SIMD3<Float> = .zero {
        didSet {
            updateMatrix()
        }
    }
    var scale: SIMD3<Float> = .one {
        didSet {
            updateMatrix()
        }
    }

    private var _matrix: float4x4 = matrix_identity_float4x4

    var matrix: float4x4 {
        matrix_multiply(parent?.matrix ?? matrix_identity_float4x4, _matrix)
    }

    init() {
        updateMatrix()
    }

    private func updateMatrix() {
        var matrix = matrix_identity_float4x4

        matrix = matrix_multiply(
            matrix,
            .init(translationBy: position)
        )
        matrix = matrix_multiply(
            matrix,
            .init(rotationAbout: .xAxis, by: rotation.x)
        )
        matrix = matrix_multiply(
            matrix,
            .init(rotationAbout: .yAxis, by: rotation.y)
        )
        matrix = matrix_multiply(
            matrix,
            .init(rotationAbout: .zAxis, by: rotation.z)
        )
        matrix = matrix_multiply(
            matrix,
            .init(scaleBy: scale)
        )

        self._matrix = matrix
    }
}
