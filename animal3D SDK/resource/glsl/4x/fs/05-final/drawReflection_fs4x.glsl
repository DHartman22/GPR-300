#version 450

layout (location = 0) out vec4 rtFragColor;
layout (binding = 4) uniform samplerCube cubeMapTex;
layout (binding = 2) uniform sampler2D testSample;

uniform samplerCube cubeMap;
uniform vec4 uCameraPos;

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
	vec3 finalView = normalize(vView - uCameraPos.xyz);
	//finalView *= vec3(1.0, 0.0, 0.0);
	vec3 ref = reflect(finalView, normalize(vNormal));
	//vec3 ref = reflect(normalize(vNormal), finalView);

	rtFragColor = texture(cubeMapTex, ref);
	
	rtFragColor.a = 1.0f;
	
}