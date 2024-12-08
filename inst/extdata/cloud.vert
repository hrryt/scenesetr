#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec4 aColor;

out vec4 crntCol;

uniform vec4 objQuat;
uniform vec3 objPos;
uniform vec4 camQuat;
uniform vec3 camPos;
uniform mat4 projMat;

vec3 rotate(vec3 position, vec4 quaternion)
{
  vec3 t = 2 * cross(quaternion.xyz, position);
  return position + quaternion.w * t + cross(quaternion.xyz, t);
}

vec4 conjugate(vec4 quaternion)
{
  quaternion.xyz *= -1;
  return quaternion;
}

void main()
{
    crntCol = aColor;
    vec3 crntPos = rotate(aPos, objQuat) + objPos;
    vec3 pos = rotate(crntPos - camPos, conjugate(camQuat));
    gl_Position = projMat * vec4(pos, 1.0);
}
