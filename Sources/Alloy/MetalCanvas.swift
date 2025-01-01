//
//  MetalCanvas.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 10.01.2024.
//

import Foundation
import SwiftUI
import MetalKit

#if os(iOS)
struct MetalCanvas: UIViewRepresentable {
    var onReady: () -> Void
    
    func updateUIView(_ uiView: MTKView, context: Context) {

    }
        
    func makeUIView(context: Context) -> MTKView {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        let view = MTKView(frame: frame, device: AERenderer.device)
        view.framebufferOnly = false
        view.delegate = context.coordinator
        view.preferredFramesPerSecond = 120
        view.clearColor = MTLClearColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        
        view.colorPixelFormat = .bgra10_xr
        view.depthStencilPixelFormat = .depth32Float
        
        context.coordinator.mtkView = view
        
        return view
    }
    
    func makeCoordinator() -> AERenderer {
        return AERenderer(onReady: onReady)
    }
}
#elseif os(macOS)
struct MetalCanvas: NSViewRepresentable {
    var onReady: () -> Void
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        
    }
    
    func makeNSView(context: Context) -> MTKView {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        let view = MTKView(frame: frame, device: AERenderer.device)
        view.framebufferOnly = false
        view.delegate = context.coordinator
        view.preferredFramesPerSecond = 120
        view.clearColor = MTLClearColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        
        view.colorPixelFormat = .bgra10_xr
        view.depthStencilPixelFormat = .depth32Float
        
        context.coordinator.mtkView = view
        
        return view
    }
    
    func makeCoordinator() -> AERenderer {
        return AERenderer(onReady: onReady)
    }
}
#endif
