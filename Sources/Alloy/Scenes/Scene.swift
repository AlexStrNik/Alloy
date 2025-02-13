//
//  Scene.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal
import simd

private class SceneObject: AEGameObject {}

open class AEScene: AEAsset {
    private var sceneObject: SceneObject

    var currentCamera: AECamera

    var currentTime: Float = 0

    var uniforms: SceneUniforms = .init(
        iTime: 0,
        deltaTime: 0,
        viewMatrix: matrix_identity_float4x4,
        projectionMatrix: matrix_identity_float4x4
    )

    init(gameObjects: [AEGameObject], currentCamera: AECamera) {
        self.sceneObject = .init()

        for gameObject in gameObjects {
            sceneObject.addChild(gameObject)
        }

        self.currentCamera = currentCamera
    }

    public func performUpdate(deltaTime: Float) {
        self.currentTime += deltaTime

        sceneObject.performUpdate(deltaTime: deltaTime)

        self.uniforms.viewMatrix = self.currentCamera.viewMatrix
        self.uniforms.projectionMatrix = self.currentCamera.projectionMatrix
        self.uniforms.iTime = self.currentTime
        self.uniforms.deltaTime = deltaTime
    }

    public func performRender(commandEncoder: MTLRenderCommandEncoder) {
        sceneObject.performRender(commandEncoder: commandEncoder)
    }

    public func instantiate(_ gameObject: AEGameObject) {
        gameObject.initialize()
        sceneObject.addChild(gameObject)
    }

    public func initialize() {
        sceneObject.initialize()
    }

    public func load() {
        AEDefaultAssets.shared.load()
    }
}
