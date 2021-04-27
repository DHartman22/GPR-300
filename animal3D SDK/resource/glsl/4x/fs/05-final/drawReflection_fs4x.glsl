#version 450

layout (location = 0) out vec4 rtFragColor;
layout (binding = 4) uniform samplerCube cubeMapTex;
layout (binding = 2) uniform sampler2D testSample;

uniform samplerCube cubeMap;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData;

in vec4 vTexcoord;
in vec3 vNormal;
in vec3 vView;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	vec3 ref = reflect(vView, normalize(vNormal));
	rtFragColor = texture(cubeMapTex, ref * -1f);
	
	rtFragColor.a = 1.0f;
	
}