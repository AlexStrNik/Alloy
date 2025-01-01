//
//  Unlit.metal
//  Alloy
//
//  Created by Aleksandr Strizhnev on 11.01.2024.
//

#include <metal_stdlib>
#include "Shared.h"
using namespace metal;

vertex FragmentIn unlit_vertex_shader(
    const VertexIn vIn [[ stage_in ]],
    constant SceneUniforms &sceneUniforms [[buffer(1)]],
    constant ModelUniforms &modelUniforms [[buffer(2)]]
) {
    FragmentIn frag;
    
    float4 worldPosition = modelUniforms.modelMatrix * float4(vIn.position, 1);
    frag.position = sceneUniforms.projectionMatrix * sceneUniforms.viewMatrix * worldPosition;
    frag.worldPosition = worldPosition.xyz;
    
    frag.uv = vIn.uv;
    
    frag.iTime = sceneUniforms.iTime;
    
    return frag;
}

fragment half4 unlit_fragment_shader(
    const FragmentIn fIn [[ stage_in ]]
) {
    return half4(fIn.uv.x, fIn.uv.y, 0, 1);
}
