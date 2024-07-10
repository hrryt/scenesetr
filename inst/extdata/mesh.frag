#version 330 core

out vec4 FragColor;

in vec3 crntPos;
in vec3 normal;
in vec4 crntCol;

uniform int nlights;
uniform float lightArray[900];
uniform vec3 camPos;

vec3 direcLight(vec3 lightPos, vec3 lightDir, vec3 lightCol)
{ 
	float ambient = 0.20f;
	float diffuse = max(dot(normal, -lightDir), 0.0f);
	float specularLight = 0.50f;
	vec3 viewDir = normalize(-crntPos);
	vec3 reflectionDir = reflect(lightDir, normal);
	float specAmount = pow(max(dot(viewDir, reflectionDir), 0.0f), 16);
	float specular = specAmount * specularLight;
	return (diffuse + ambient + specular) * lightCol * crntCol.rgb;
}

vec4 iterate_over_lights()
{
  vec3 lightPos;
  vec3 lightDir;
  vec3 lightCol;
  vec3 outColor = vec3(0.0);
  for (int i=0; i<nlights; i++) {
    int idx = 9*i;
	  lightPos = vec3(lightArray[0+idx], lightArray[1+idx], lightArray[2+idx]);
    lightDir = vec3(lightArray[3+idx], lightArray[4+idx], lightArray[5+idx]);
    lightCol = vec3(lightArray[6+idx], lightArray[7+idx], lightArray[8+idx]);
    outColor = outColor + direcLight(lightPos, lightDir, lightCol);
	}
	return vec4(min(outColor.x, 1.0), min(outColor.y, 1.0), min(outColor.z, 1.0), crntCol.a);
}

void main()
{
  FragColor = iterate_over_lights();
}