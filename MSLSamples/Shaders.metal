//
//  Shaders.metal
//  MetalShaderColorFill
//
//  Created by Shuichi Tsutsumi on 2017/09/23.
//  Copyright © 2017 Shuichi Tsutsumi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertexShader(constant float4 *positions [[ buffer(0) ]],
                                        uint    vid       [[ vertex_id ]])
{
    return positions[vid];
}

float4 circle(float2 uv, float2 pos, float rad, float3 color) {
    float d = length(pos - uv) - rad;
    float t = clamp(d, 0.0, 1.0);
    return float4(color, 1.0 - t);
}

fragment float4 fragmentShader(float4 pixPos [[position]],
                               constant float2& res [[buffer(0)]])
{
    float2 uv = pixPos.xy;
    float2 center = res.xy * 0.5;
    
    float radius = 0.1 * res.x;

    // Background layer
    float4 layer1 = float4(0, 1, 0, 1.0);
    
    // Circle
    float3 red = float3(1, 0, 0);
    float4 layer2 = circle(uv, center, radius, red);
    
    // Blend the two
    float4 fragColor = mix(layer1, layer2, layer2.a);
    return fragColor;
}

fragment float4 fragment_circle(float4 pixPos [[position]],
                              constant float2& res [[buffer(0)]]) {
    
    float2 uv = pixPos.xy;
    float2 center = res.xy * 0.5;
    
    float radius = 0.25 * res.y;

    // Background layer
    float4 layer1 = float4(0, 1, 0, 1.0);
    
    // Circle
    float3 red = float3(1, 0, 0);
    float4 layer2 = circle(uv, center, radius, red);
    
    // Blend the two
    float4 fragColor = mix(layer1, layer2, layer2.a);
    return fragColor;
}
