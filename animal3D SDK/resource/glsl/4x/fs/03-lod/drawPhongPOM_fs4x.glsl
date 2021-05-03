/*
	Copyright 2011-2021 Daniel S. Buckstein
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
		http://www.apache.org/licenses/LICENSE-2.0
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhongPOM_fs4x.glsl
	Output Phong shading with parallax occlusion mapping (POM).
*/
//Edited by Nick Preis and Daniel Hartman

#version 450

layout (binding = 4) uniform samplerCube cubeMapTex;
uniform vec4 uCameraPos;


#define MAX_LIGHTS 1024

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

struct sPointLight
{
	vec4 viewPos, worldPos, color, radiusInfo;
};

uniform ubLight
{
	sPointLight uPointLight[MAX_LIGHTS];
};

uniform int uCount;

uniform vec4 uColor;

uniform float uSize;

uniform sampler2D uTex_dm, uTex_sm, uTex_nm, uTex_hm;

const vec4 kEyePos = vec4(0.0, 0.0, 0.0, 1.0);

const float depthScale = 0.02f;
const float reflectionPower = 0.5f;

layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtFragNormal;

in vec3 vNormal;
in vec3 vView;

void calcPhongPoint(out vec4 diffuseColor, out vec4 specularColor, in vec4 eyeVec,
	in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor);
	
vec3 calcParallaxCoord(in vec3 coord, in vec3 viewVec, const int steps)
{
	// ****DONE:
	//	-> step along view vector until intersecting height map
	//	-> determine precise intersection point, return resulting coordinate

	//using learnopengl as a reference https://learnopengl.com/Advanced-Lighting/Parallax-Mapping
	//as well as the lecture 10 slides
	//update 4-14-21: upon reexamining this code, it borrowed a bit too much from learnopengl, so its
	// not entirely accurate to say I used it simply as a reference, so I only claim full ownership over 
	// the code from line 95 downwards
	
	float stepLength = 1.0 / steps;
	float currentStepValue = 0.0; 
	float depthValue = texture(uTex_hm, coord.xy).r; 

	vec3 P = viewVec * depthScale;
	vec3 deltaTexCoord = P / steps;

	vec3 originalCoord = coord; //save original for interp

	while(currentStepValue <= depthValue) // <= just in case it miraculously lands on the perfect spot
	{
		coord += deltaTexCoord; //take a step
		depthValue = texture(uTex_hm, coord.xy).r; //sample the height map to check if we've reached the parallax coord yet
		currentStepValue += stepLength;
	} 

	vec3 previousStepCoord = coord - deltaTexCoord;
	float previousStepCoordDepth = texture(uTex_hm, previousStepCoord.xy).r - depthValue + stepLength;

	float deltaH = previousStepCoord.y - coord.y;
	float deltaB = previousStepCoordDepth - depthValue;

	float x = (previousStepCoord.y - previousStepCoordDepth) / (deltaB - deltaH);

	vec3 final = mix(previousStepCoord, coord, x); //find x in y = mx + b
	// done
	return final;
}

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE GREEN
	//	rtFragColor = vec4(0.0, 1.0, 0.0, 1.0);

	vec4 diffuseColor = vec4(0.0), specularColor = diffuseColor, dd, ds;
	
	// view-space tangent basis
	vec4 tan_view = normalize(vTangentBasis_view[0]);
	vec4 bit_view = normalize(vTangentBasis_view[1]);
	vec4 nrm_view = normalize(vTangentBasis_view[2]);
	vec4 pos_view = vTangentBasis_view[3];
	
	// view-space view vector
	vec4 viewVec = normalize(kEyePos - pos_view);
	
	// ****TO-DO:
	//	-> convert view vector into tangent space
	//		(hint: the above TBN bases convert tangent to view, figure out 
	//		an efficient way of representing the required matrix operation)
	// tangent-space view vector
	vec3 viewVec_tan = vec3(
		tan_view.x,
		tan_view.y,
		tan_view.z
	);

	mat3 tbn = {tan_view.xyz, bit_view.xyz, nrm_view.xyz}; //create matrix manually so I can inverse it

	viewVec_tan = inverse(tbn) * viewVec.xyz; //view -> tangent
	// parallax occlusion mapping
	vec3 texcoord = vec3(vTexcoord_atlas.xy, uSize);
	texcoord = calcParallaxCoord(texcoord, viewVec_tan, 256);
	
	// read and calculate view normal
	vec4 sample_nm = texture(uTex_nm, texcoord.xy);
	nrm_view = mat4(tan_view, bit_view, nrm_view, kEyePos)
		* vec4((sample_nm.xyz * 2.0 - 1.0), 0.0);
	
	int i;
	for (i = 0; i < uCount; ++i)
	{
		calcPhongPoint(dd, ds, viewVec, pos_view, nrm_view, uColor, 
			uPointLight[i].viewPos, uPointLight[i].radiusInfo,
			uPointLight[i].color);
		diffuseColor += dd;
		specularColor += ds;
	}

	vec4 sample_dm = texture(uTex_dm, texcoord.xy);
	vec4 sample_sm = texture(uTex_sm, texcoord.xy);
	vec3 finalView = normalize(vView.xyz - uCameraPos.xyz);

	//Uses normal of plane rather than 
		vec3 ref = reflect(finalView, normalize(vNormal));
	//Use same ray rotation method from reflection shader
	vec3 ref2 = ref;
	ref.z = ref.y;
	ref.y = ref2.z;

		mat3 rot = mat3(-1.0, 0, 0,
					0, 1.0, 0,
					0, 0, -1.0);

	vec4 sample_reflect = texture(cubeMapTex, ref * -1 * rot);

	rtFragColor = sample_dm * diffuseColor + sample_sm * specularColor + sample_reflect * reflectionPower; //weight variable to ensure the reflection doesn't overpower everything
	rtFragColor.a = sample_dm.a;
	
	// MRT
	rtFragNormal = vec4(nrm_view.xyz * 0.5 + 0.5, 1.0);
	
	// DEBUGGING
	//rtFragColor.rgb = vNormal;
}