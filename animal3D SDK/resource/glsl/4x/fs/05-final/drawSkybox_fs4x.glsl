#version 450

layout (location = 0) out vec4 rtFragColor;
layout (binding = 4) uniform samplerCube cubeMapTex;
layout (binding = 2) uniform sampler2D testSample;

uniform samplerCube cubeMap;
uniform vec4 uCameraPos;

in vec4 vTexcoord;
in vec3 vNormal;
in vec3 vView;

void main()
{

mat3 rot = mat3(1.0, 0, 0,
		0, -1, 0,
		0, 0, -1.0);
	rtFragColor = texture(cubeMapTex, vTexcoord.xyz * rot); 
	//Z is up in animal3d, so flip it
	
	rtFragColor.a = 1.0f;
	
}