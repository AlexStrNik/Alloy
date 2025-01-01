//
//  Shared.metal
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

#ifndef SHARED
#define SHARED

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct FragmentIn {
    float4 position [[ position ]];
    float3 worldPosition;
    float2 uv;
    float iTime;
};

struct InstancedFragmentIn {
    float4 position [[ position ]];
    float3 worldPosition;
    float2 uv;
    uint instance;
    float iTime;
};

struct ModelUniforms {
    float4x4 modelMatrix;
};

struct SceneUniforms {
    float iTime;
    float deltaTime;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct Particle {
    float3 position;
    float3 velocity;
    float scale;
    float age;
};

float rand(int x, int y, thread float* z);

#endif
