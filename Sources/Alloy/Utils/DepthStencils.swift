//
//  DepthStencils.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

import Foundation
import Metal

enum DepthStencil: Hashable {
    case less
    case disabled
}

struct DepthStencilsCache {
    private var cache: [DepthStencil: MTLDepthStencilState] = [:]

    static var shared: DepthStencilsCache = .init()

    private init() {}

    subscript(_ stencil: DepthStencil) -> MTLDepthStencilState? {
        get {
            return cache[stencil]
        }
        set(newValue) {
            cache[stencil] = newValue
        }
    }
}

public struct AEDepthStencils {
    public static func makeLessDepthStencil() -> MTLDepthStencilState {
        if let state = DepthStencilsCache.shared[.less] {
            return state
        }

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true

        let state = AERenderer.device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        DepthStencilsCache.shared[.less] = state

        return state
    }

    public static func makeDisabledDepthStencil() -> MTLDepthStencilState {
        if let state = DepthStencilsCache.shared[.disabled] {
            return state
        }

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = false

        let state = AERenderer.device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        DepthStencilsCache.shared[.disabled] = state

        return state
    }

    private init() {}
}
