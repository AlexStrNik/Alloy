//
//  Camera.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal
import simd

open class AECamera: AEGameObject {
    var fov: Float = 60 {
        didSet {
            updateProjectionMatrix()
        }
    }
    var aspectRatio: Float = 0 {
        didSet {
            updateProjectionMatrix()
        }
    }
    var nearClipping: Float = 0.001 {
        didSet {
            updateProjectionMatrix()
        }
    }
    var farClipping: Float = 100 {
        didSet {
            updateProjectionMatrix()
        }
    }

    private(set) var projectionMatrix: float4x4 = matrix_identity_float4x4

    var viewMatrix: float4x4 {
        self.transform.matrix.inverse
    }

    override init() {
        super.init()
        updateProjectionMatrix()
    }

    private func updateProjectionMatrix() {
        let fovRadians = fov / 180 * .pi

        let t: Float = tan(fovRadians / 2)

        let x: Float = 1 / (aspectRatio * t)
        let y: Float = 1 / t
        let z: Float = -((farClipping + nearClipping) / (farClipping - nearClipping))
        let w: Float = -((2 * farClipping * nearClipping) / (farClipping - nearClipping))

        self.projectionMatrix = .init(
            .init(x, 0, 0, 0),
            .init(0, y, 0, 0),
            .init(0, 0, z, -1),
            .init(0, 0, w, 0)
        )
    }
}
