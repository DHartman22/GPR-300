#version 450

layout (location = 0) out vec4 rtFragColor;
layout (binding = 4) uniform sampler2D cubeMapTex;
uniform samplerCube cubeMap;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	rtFragColor = texture(cubeMapTex, vec2(0.0, 0.0));
	
}