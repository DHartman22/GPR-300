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
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/
//Edited by Daniel Hartman and Nick Preis

#version 450

// ****DONE:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

layout (location = 0) out vec4 rtFragColor;
layout (binding = 6) uniform sampler2D uTex_shadow; //taken directly from blue book pg 653

uniform int uCount;

in vec4 vView;
in vec4 vNormal;
in vec4 vPosition;
in vec2 vTexcoord;
in vec4 vShadowCoord;

in vec4 vLightPos;
in vec4 vLightColor;
in float vLightRadii;

uniform vec4 uColor;
uniform sampler2D uSampler;

struct sPointLightData
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	float radius;						// radius (distance of effect from center)
	float radiusSq;					// radius squared (if needed)
	float radiusInv;					// radius inverse (attenuation factor)
	float radiusInvSq;					// radius inverse squared (attenuation factor)
};

uniform ubLight
{
	sPointLightData uPointLightData[4];
};


void main()
{
	//normal and view vectors are not light specific
	vec4 N = normalize(vNormal);
	vec4 V = normalize(vView * -1);

	vec4 finalOutput = vec4(0.0); //used to add up results of the loop below and pass to rtFragColor


	//blue book helped a lot with this
	for(int i = 0; i < uCount; i++) //uCount = number of lights active in the scene
	{
		vec4 lightDirectionFull = uPointLightData[i].position - vPosition; //used later to calculate distance from light
		vec4 L = normalize(lightDirectionFull);
		vec4 R = reflect(-L, N);

		float lightDistance = length(lightDirectionFull); 

		float attenuation = clamp(uPointLightData[i].radiusSq / lightDistance, 0.0, 1.0);

		vec4 diffuse = max(dot(N, L), 0.0) * texture2D(uSampler, vTexcoord) * uPointLightData[i].color; //applies texture and light color
		vec4 specular = pow(max(dot(V, R), 0.0), 128.0) * uPointLightData[i].color; //specular color is the same as the light color

		finalOutput += attenuation * vec4(diffuse + specular);
	}

	//textureProj performs the perspective divide
	rtFragColor = textureProj(uTex_shadow, vShadowCoord) * finalOutput;
}
