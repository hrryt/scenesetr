#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColour;

out vec3 colour;

uniform float time;
uniform mat4 camMatrix;

void main()
{
    colour = aColour;
    gl_Position = camMatrix * vec4(aPos.x, aPos.y, aPos.z, 1.0);
}