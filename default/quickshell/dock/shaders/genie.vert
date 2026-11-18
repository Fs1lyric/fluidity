#version 440
layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;
layout(location = 0) out vec2 texCoord;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 windowRect;
    vec4 iconRect;
    vec4 sourceRect;
    float progress;
};
void main() {
    texCoord = qt_MultiTexCoord0;
    vec2 uv = qt_MultiTexCoord0;
    vec2 original = windowRect.xy + uv * windowRect.zw;
    vec2 target = iconRect.xy + uv * iconRect.zw;
    // The lower edge narrows first, then the whole sheet is drawn into the icon.
    float bend = smoothstep(0.0, 1.0, uv.y + progress * 2.0 - 1.0);
    float travel = smoothstep(0.25, 1.0, progress);
    vec2 position = mix(original, target, travel);
    position.x = mix(original.x, target.x, max(bend, travel));
    gl_Position = qt_Matrix * vec4(position, 0.0, 1.0);
}
