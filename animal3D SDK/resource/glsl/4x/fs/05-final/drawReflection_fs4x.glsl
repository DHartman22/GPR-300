#version 450
//Daniel Hartman

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
	vec3 finalView = normalize(vView - uCameraPos.xyz);

	vec3 ref = reflect(finalView, normalize(vNormal));
	//Not the cleanest method, but it works
	vec3 ref2 = ref;
	ref.z = ref.y;
	ref.y = ref2.z;
	mat3 rot = mat3(-1.0, 0, 0,
					0, 1.0, 0,
					0, 0, -1.0);
	
	rtFragColor = texture(cubeMapTex, ref * -1 * rot);
	//Z is up in animal3d 
	
	rtFragColor.a = 1.0f;
	
}