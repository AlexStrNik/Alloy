//
//  Particles.metal
//  Alloy
//
//  Created by Aleksandr Strizhnev on 18.01.2024.
//

#include <metal_stdlib>
#include "../Shaders/Shared.h"
using namespace metal;

struct EmitterUniforms {
    float3x2 position;
    float2 scale;
    float3x2 velocity;
    float2 lifeTime;
    uint32_t aliveParticles;
    int32_t rngSeedX;
    int32_t rngSeedY;
};

kernel void emit_particles(
    device Particle *particles [[ buffer(0) ]],
    constant EmitterUniforms &emitterUniforms [[ buffer(1) ]],
    constant ModelUniforms &modelUniforms [[buffer(2)]],
    uint id [[ thread_position_in_grid ]]
){
    float rnd = float(id) / 10;
    #define rand_float(a, b) mix(a, b, rand(emitterUniforms.rngSeedX, emitterUniforms.rngSeedY, &rnd))
    
    Particle particle;
    particle.age = rand_float(emitterUniforms.lifeTime.x, emitterUniforms.lifeTime.y);
    particle.scale = rand_float(emitterUniforms.scale.x, emitterUniforms.scale.y);
    particle.position = (
        modelUniforms.modelMatrix * float4(
            rand_float(emitterUniforms.position[0].x, emitterUniforms.position[0].y),
            rand_float(emitterUniforms.position[1].x, emitterUniforms.position[1].y),
            rand_float(emitterUniforms.position[2].x, emitterUniforms.position[2].y),
            1
        )
    ).xyz;
    particle.velocity = float3(
        rand_float(emitterUniforms.velocity[0].x, emitterUniforms.velocity[0].y),
        rand_float(emitterUniforms.velocity[1].x, emitterUniforms.velocity[1].y),
        rand_float(emitterUniforms.velocity[2].x, emitterUniforms.velocity[2].y)
    );
    
    #undef rand_float
    
    particles[emitterUniforms.aliveParticles + id] = particle;
}

kernel void update_particles(
    device Particle *particles [[ buffer(0) ]],
    constant SceneUniforms *sceneUniforms [[ buffer(1) ]],
    uint id [[ thread_position_in_grid ]]
){
    Particle particle;
    particle = particles[id];
    
    particle.age -= sceneUniforms->deltaTime;
    particle.position += particle.velocity * sceneUniforms->deltaTime;
    
    particles[id] = particle;
}

kernel void sort_particles(
    device Particle *particles0 [[ buffer(0) ]],
    device Particle *particles1 [[ buffer(1) ]],
    device atomic_uint &aliveCounter [[buffer(2)]],
    uint id [[ thread_position_in_grid ]]
){
    if (id == 0) {
        atomic_store_explicit(&aliveCounter, 0, memory_order_relaxed);
    }
    threadgroup_barrier(mem_flags::mem_device);
    
    if (particles0[id].age > 0) {
        uint index = atomic_fetch_add_explicit(&aliveCounter, 1, memory_order_relaxed);
        particles1[index] = particles0[id];
    }
}

vertex FragmentIn particles_vertex_shader(
    const VertexIn vIn [[ stage_in ]],
    constant SceneUniforms &sceneUniforms [[buffer(1)]],
    constant Particle *particlesUniforms [[buffer(2)]],
    uint instanceId [[ instance_id ]]
) {
    FragmentIn frag;
   
    float scale = particlesUniforms[instanceId].scale;
    float4x4 scaleMatrix = float4x4(
        {scale, .0, .0, .0},
        {.0, scale, .0, .0},
        {.0, .0, scale, .0},
        {.0, .0, .0, .1}
    );
    
    float3 translation = particlesUniforms[instanceId].position;
    float4x4 translateMatrix = float4x4(
        {.1, .0, .0, .0},
        {.0, .1, .0, .0},
        {.0, .0, .1, .0},
        {translation.x, translation.y, translation.z, .1}
    );
    
    float4x4 particleMatrix = translateMatrix * scaleMatrix;
    
    float4 worldPosition = particleMatrix * float4(vIn.position, 1);
    frag.position = sceneUniforms.projectionMatrix * sceneUniforms.viewMatrix * worldPosition;
    frag.worldPosition = worldPosition.xyz;
    
    frag.uv = vIn.uv;
    
    frag.iTime = sceneUniforms.iTime;
    
    return frag;
}

fragment half4 particles_fragment_shader(
    const FragmentIn fIn [[ stage_in ]],
    constant Particle *particlesUniforms [[buffer(1)]]
) {
    return half4(fIn.uv.x, fIn.uv.y, 0, 1);
}
