//
//  Shared.metal
//  Alloy
//
//  Created by Aleksandr Strizhnev on 19.01.2024.
//

#include <metal_stdlib>
#include "../Shaders/Shared.h"
using namespace metal;

float rand(int x, int y, thread float* z) {
    int seed = x + y * 57 + *z * 241;
    seed= (seed<< 13) ^ seed;
    *z = (( 1.0 - ((seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
    
    return *z;
}
