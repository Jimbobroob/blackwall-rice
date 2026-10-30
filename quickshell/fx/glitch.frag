#version 440
// Pop-in glitch: horizontal slice displacement + RGB split on a sampled item.
// progress runs 1 -> 0; strength is the max slice shift as a fraction of width.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float strength;
    float seed;
};
layout(binding = 1) uniform sampler2D source;

float hash(float n) { return fract(sin(n * 91.345 + seed * 17.13) * 43758.5453); }

vec4 tap(vec2 uv) {
    float inside = step(0.0, uv.x) * step(uv.x, 1.0);
    return texture(source, clamp(uv, 0.0, 1.0)) * inside;
}

void main() {
    vec2 uv = qt_TexCoord0;
    float p = progress;
    float band = floor(uv.y * 22.0);
    float hit = step(1.0 - p * 0.85, hash(band));
    float off = (hash(band + 7.0) - 0.5) * 2.0 * strength * p * hit;
    float split = strength * 0.6 * p;
    vec2 u = vec2(uv.x + off, uv.y);
    vec4 c = vec4(tap(u + vec2(split, 0.0)).r, tap(u).g, tap(u - vec2(split, 0.0)).b, tap(u).a);
    // flicker: sparse early, solid by the end
    float vis = step(hash(floor(p * 14.0) + 3.0), 1.0 - p * 0.6);
    fragColor = c * vis * qt_Opacity;
}
