#version 330 core

out vec4 FragColor;

in vec4 crntCol;

void main()
{
  FragColor = crntCol;
}
