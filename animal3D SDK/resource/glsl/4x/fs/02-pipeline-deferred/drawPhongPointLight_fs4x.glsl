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
	
	drawPhongPointLight_fs4x.glsl
	Output Phong shading components while drawing point light volume.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> declare biased clip coordinate varying from vertex shader
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> calculate screen-space coordinate from biased clip coord
//		(hint: perspective divide)
//	-> use screen-space coord to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: same as deferred shading)
//	-> calculate final diffuse and specular shading for current light only

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
	sPointLightData uPointLightData[MAX_LIGHTS];
};

float attenuation(in float dist, in float distSq, in float lightRadiusInv, in float lightRadiusInvSq);

flat in int vInstanceID;

layout (location = 0) out vec4 rtDiffuseLight;
layout (location = 1) out vec4 rtSpecularLight;

in vec4 vPosition_biased_clip;

uniform sampler2D uImage00; //diffuse
uniform sampler2D uImage01; //specular

uniform sampler2D uImage04; //scene texcoord
uniform sampler2D uImage05; //scene normals
//uniform sampler2D uImage06; //scene "positions"
uniform sampler2D uImage07; //scene depth

uniform mat4 uPB_inv;  //Inverse bias projection

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
	vec4 screenSpace = vPosition_biased_clip / vPosition_biased_clip.w;
	vec4 sceneTexcoord = texture(uImage04, screenSpace.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);

	vec4 diffuseSpec = diffuseSample * specularSample;

	vec4 normal = texture(uImage05, sceneTexcoord.xy);
	vec4 position = texture(uImage04, sceneTexcoord.xy);
	float specularPower = 32.0f;

	vec4 position_screen = screenSpace;
	position_screen.z = texture(uImage07, screenSpace.xy).r;

	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w;

	vec4 normal_view = texture(uImage05, screenSpace.xy);
	normal_view = (normal_view - 0.5) * 2.0;

	vec4 N = normalize(normal_view);
	vec4 final = vec4(0.0);
	

		vec4 lightDirectionFull = uPointLightData[vInstanceID].position - position_view; //used later to calculate distance from light
		vec4 L = normalize(lightDirectionFull);
		vec4 R = reflect(-L, N);

		float lightDistance = length(lightDirectionFull); 

		float attenuation = attenuation(lightDistance, dot(lightDistance, lightDistance), uPointLightData[vInstanceID].radiusInv, uPointLightData[vInstanceID].radiusInvSq);

		vec4 diffuse = max(dot(N, L), 0.0) * diffuseSample * uPointLightData[vInstanceID].color; //applies texture and light color
		vec4 specular = pow(max(dot(position_view, R), 0.0), specularPower) * uPointLightData[vInstanceID].color; //specular color is the same as the light color
		

		final += attenuation * vec4(diffuse);
	

	rtDiffuseLight = vec4(final);

	//https://learnopengl.com/Advanced-Lighting/Deferred-Shading

	//rtFragColor.a = diffuseSample.a;
}
