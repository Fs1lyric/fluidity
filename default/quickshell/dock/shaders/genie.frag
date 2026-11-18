#version 440
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 windowRect;
    vec4 iconRect;
    vec4 sourceRect;
    float progress;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    fragColor = texture(source, sourceRect.xy + texCoord * sourceRect.zw) * qt_Opacity;
}
