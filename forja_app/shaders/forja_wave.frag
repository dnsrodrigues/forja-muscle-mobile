#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;    // tamanho do canvas em pixels
uniform float uTime;   // tempo em segundos
uniform vec3 uAccent;  // cor de acento (componentes 0..1)

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;

  // fase das ondas horizontais
  float phase = uv.x * 6.2831853 * 2.0 + uTime * 1.5;

  // aberração cromática: cada canal com leve defasagem
  float r = 0.5 + 0.5 * sin(phase + 0.12 + uv.y * 3.0);
  float g = 0.5 + 0.5 * sin(phase + uv.y * 3.0);
  float b = 0.5 + 0.5 * sin(phase - 0.12 + uv.y * 3.0);

  vec3 col = uAccent * vec3(r, g, b);

  // brilho ondulado e fade vertical em direção ao escuro na base
  float fade = smoothstep(1.0, 0.15, uv.y);
  col *= fade;

  fragColor = vec4(col, 1.0);
}
