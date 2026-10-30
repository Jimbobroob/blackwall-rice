#version 440
// Workspace-switch flash: a few red/magenta horizontal tears that fade out. progress 1 -> 0.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float intensity;
    float seed;
    vec4 red;
    vec4 magenta;
};

float hash(float n) { return fract(sin(n * 78.233 + seed * 12.9898) * 43758.5453); }

void main() {
    vec2 uv = qt_TexCoord0;
    float p = progress;
    float band = floor(uv.y * (60.0 + hash(1.0) * 60.0) + floor(p * 6.0) * 3.0);
    float hit = step(1.0 - 0.12 * p, hash(band));
    float len = 0.15 + 0.7 * hash(band + 1.0);
    float start = hash(band + 2.0) * (1.0 - len);
    float inx = step(start, uv.x) * step(uv.x, start + len);
    vec4 col = mix(red, magenta, step(0.7, hash(band + 4.0)));
    float a = hit * inx * p * intensity;
    // premultiplied
    fragColor = vec4(col.rgb * a, a) * qt_Opacity;
}
