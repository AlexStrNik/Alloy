//
//  Renderer.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 10.01.2024.
//

import Foundation
import MetalKit

public class AERenderer: NSObject, MTKViewDelegate {
    static var device: MTLDevice!
    static var library: MTLLibrary!
    static var commandQueue: MTLCommandQueue!
    static var textureLoader: MTKTextureLoader!

    static var currentScene: AEScene?

    static var colorPixelFormat: MTLPixelFormat!
    static var depthStencilPixelFormat: MTLPixelFormat!

    static var aspectRatio: Float = 1

    private var onReady: () -> Void

    private static var isPaused: Bool = true

    var mtkView: MTKView! {
        didSet {
            AERenderer.colorPixelFormat = mtkView.colorPixelFormat
            AERenderer.depthStencilPixelFormat = mtkView.depthStencilPixelFormat

            onReady()
        }
    }

    init(onReady: @escaping () -> Void) {
        AERenderer.device = MTLCreateSystemDefaultDevice()!
        AERenderer.library = AERenderer.device.makeDefaultLibrary()!
        AERenderer.commandQueue = AERenderer.device.makeCommandQueue()!
        AERenderer.textureLoader = MTKTextureLoader(device: AERenderer.device)

        self.onReady = onReady

        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        AERenderer.aspectRatio = Float(view.bounds.width / view.bounds.height)
        if let currentScene = AERenderer.currentScene {
            currentScene.currentCamera.aspectRatio = AERenderer.aspectRatio
        }
    }

    func draw(in view: MTKView) {
        guard let currentScene = AERenderer.currentScene, !AERenderer.isPaused else {
            return
        }
        currentScene.performUpdate(deltaTime: 1.0 / Float(view.preferredFramesPerSecond))

        let commandBuffer = AERenderer.commandQueue.makeCommandBuffer()!

        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable
        else {
            return
        }

        let commandEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor)!

        currentScene.performRender(commandEncoder: commandEncoder)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    static func loadScene(_ scene: AEScene) {
        AERenderer.currentScene = scene
        scene.load()
        scene.initialize()
        scene.currentCamera.aspectRatio = AERenderer.aspectRatio
    }

    static func pause() {
        AERenderer.isPaused = true
    }

    static func play() {
        AERenderer.isPaused = false
    }

    static func togglePlay() {
        if AERenderer.isPaused {
            play()
        } else {
            pause()
        }
    }
}
