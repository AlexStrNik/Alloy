//
//  MetalCanvas.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 10.01.2024.
//

import Foundation
import MetalKit
import SwiftUI

#if os(iOS)
    public struct MetalCanvas: UIViewRepresentable {
        public var onReady: () -> Void

        public init(onReady: @escaping () -> Void) {
            self.onReady = onReady
        }

        public func updateUIView(_ uiView: MTKView, context: Context) {

        }

        public func makeUIView(context: Context) -> MTKView {
            let frame = CGRect(x: 0, y: 0, width: 300, height: 300)

            let view = MTKView(frame: frame, device: AERenderer.device)
            view.framebufferOnly = false
            view.delegate = context.coordinator
            view.preferredFramesPerSecond = 120
            view.clearColor = MTLClearColor.init(red: 0, green: 0, blue: 0, alpha: 0)

            view.colorPixelFormat = .bgra10_xr
            view.depthStencilPixelFormat = .depth32Float

            view.layer.isOpaque = false
            view.isOpaque = false
            view.backgroundColor = .clear

            context.coordinator.mtkView = view

            return view
        }

        public func makeCoordinator() -> AERenderer {
            return AERenderer(onReady: onReady)
        }
    }
#elseif os(macOS)
    public struct MetalCanvas: NSViewRepresentable {
        public var onReady: () -> Void

        public init(onReady: @escaping () -> Void) {
            self.onReady = onReady
        }

        public func updateNSView(_ nsView: MTKView, context: Context) {

        }

        public func makeNSView(context: Context) -> MTKView {
            let frame = CGRect(x: 0, y: 0, width: 300, height: 300)

            let view = MTKView(frame: frame, device: AERenderer.device)
            view.framebufferOnly = false
            view.delegate = context.coordinator
            view.preferredFramesPerSecond = 120
            view.clearColor = MTLClearColor.init(red: 0, green: 0, blue: 0, alpha: 0)

            view.colorPixelFormat = .bgra10_xr
            view.depthStencilPixelFormat = .depth32Float

            view.layer?.isOpaque = false

            context.coordinator.mtkView = view

            return view
        }

        public func makeCoordinator() -> AERenderer {
            return AERenderer(onReady: onReady)
        }
    }
#endif
