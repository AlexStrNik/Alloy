//
//  Samplers.swift
//  Alloy
//
//  Created by Aleksandr Strizhnev on 12.01.2024.
//

import Foundation
import Metal

enum Sampler {
    case linear
}

struct SamplersCache {
    private var cache: [Sampler: MTLSamplerState] = [:]
    
    static var shared: SamplersCache = .init()
    
    private init() {}
    
    subscript(_ sampler: Sampler) -> MTLSamplerState? {
        get {
            return cache[sampler]
        }
        set(newValue) {
            cache[sampler] = newValue
        }
    }
}

struct Samplers {
    static func makeLinearSampler() -> MTLSamplerState {
        if let state = SamplersCache.shared[.linear] {
            return state
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
            
        let state = AERenderer.device.makeSamplerState(descriptor: samplerDescriptor)!
        SamplersCache.shared[.linear] = state
        
        return state
    }
    
    private init () {}
}
