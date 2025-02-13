//
//  ComputeStates.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

import Foundation
import Metal

struct ComputeStatesCache {
    private var cache: [String: MTLComputePipelineState] = [:]

    static var shared: ComputeStatesCache = .init()

    private init() {}

    subscript(_ name: String) -> MTLComputePipelineState? {
        get {
            return cache[name]
        }
        set(newValue) {
            cache[name] = newValue
        }
    }
}

public struct AEComputeStates {
    public static func makeComputeState(for shader: AEShader) -> MTLComputePipelineState {
        if let state = ComputeStatesCache.shared[shader.name] {
            return state
        }

        let state = try! AERenderer.device.makeComputePipelineState(function: shader.load())
        ComputeStatesCache.shared[shader.name] = state

        return state
    }

    private init() {}
}
