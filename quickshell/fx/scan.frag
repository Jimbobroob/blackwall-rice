#version 440
// Scanlines clipped to a rounded rectangle, so they never poke out of a card's corners.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    float radius;
    float pitch;
    float alpha;
};

void main() {
    vec2 p = qt_TexCoord0 * size;
    vec2 q = abs(p - size * 0.5) - (size * 0.5 - vec2(radius));
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
    float inside = 1.0 - smoothstep(-1.0, 0.0, d);
    float line = step(0.5, fract(p.y / pitch));
    fragColor = vec4(0.0, 0.0, 0.0, alpha * line * inside) * qt_Opacity;
}
