//
//  Renderer.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 10.01.2024.
//

import Foundation
import MetalKit

open class AERenderer: NSObject, MTKViewDelegate {
    public static var device: MTLDevice!
    static var internalLibrary: MTLLibrary!
    public static var library: MTLLibrary!
    public static var commandQueue: MTLCommandQueue!
    public static var textureLoader: MTKTextureLoader!

    public static var currentScene: AEScene?

    public static var colorPixelFormat: MTLPixelFormat!
    public static var depthStencilPixelFormat: MTLPixelFormat!

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
        AERenderer.internalLibrary = try! AERenderer.device.makeDefaultLibrary(
            bundle: Bundle.module
        )
        AERenderer.commandQueue = AERenderer.device.makeCommandQueue()!
        AERenderer.textureLoader = MTKTextureLoader(device: AERenderer.device)

        self.onReady = onReady

        super.init()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        AERenderer.aspectRatio = Float(view.bounds.width / view.bounds.height)
        if let currentScene = AERenderer.currentScene {
            currentScene.currentCamera.aspectRatio = AERenderer.aspectRatio
        }
    }

    public func draw(in view: MTKView) {
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

    public static func loadScene(_ scene: AEScene) {
        AERenderer.currentScene = scene
        scene.load()
        scene.initialize()
        scene.currentCamera.aspectRatio = AERenderer.aspectRatio
    }

    public static func pause() {
        AERenderer.isPaused = true
    }

    public static func play() {
        AERenderer.isPaused = false
    }

    public static func togglePlay() {
        if AERenderer.isPaused {
            play()
        } else {
            pause()
        }
    }
}
