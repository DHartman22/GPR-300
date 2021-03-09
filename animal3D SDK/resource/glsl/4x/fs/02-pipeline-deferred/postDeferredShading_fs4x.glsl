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
	
	postDeferredShading_fs4x.glsl
	Calculate full-screen deferred Phong shading.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> this one is pretty similar to the forward shading algorithm (Phong NM) 
//		except it happens on a plane, given images of the scene's geometric 
//		data (the "g-buffers"); all of the information about the scene comes 
//		from screen-sized textures, so use the texcoord varying as the UV
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> use screen-space coord (the inbound UV) to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: modify screen-space coord, use appropriate matrix to get it 
//		back to view-space, perspective divide)
//	-> calculate and accumulate final diffuse and specular shading

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


in vec4 vTexcoord_atlas;

uniform int uCount;

uniform sampler2D uImage00; //diffuse
uniform sampler2D uImage01; //specular

uniform sampler2D uImage04; //scene texcoord
uniform sampler2D uImage05; //scene normals
//uniform sampler2D uImage06; //scene "positions"
uniform sampler2D uImage07; //scene depth

uniform mat4 uPB_inv;  //Inverse bias projection


//testing
//uniform sampler2D uImage02, uImage03;

layout (location = 0) out vec4 rtFragColor;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);

	//Phong: ambient + (diffuse color * diffuse light) 
	// + (specular color * specular light)

	//Have:
	//	Diffuse and specular color. Stored in atlases
	//Missing:
	//	Light data, which is a uniform
	//	Model/Scene data -> Attributes
	//		-> some frame buffer
	//			-> texcoords, normals, positions
	//				stored in g-buffers

	//draw objects with diffuse texture applied
	//	use screen space coordinate to sample
	//		uImage04 (scene texcoord)
	//	we also have texture
	//	Sample atlas using scene texcoord
	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);

	vec4 diffuseSpec = diffuseSample * specularSample;

	vec4 normal = texture(uImage05, sceneTexcoord.xy);
	vec4 position = texture(uImage04, sceneTexcoord.xy);
	float specularPower = 32.0f;

	vec4 position_screen = vTexcoord_atlas;
	position_screen.z = texture(uImage07, vTexcoord_atlas.xy).r;

	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w;

	vec4 normal_view = texture(uImage05, vTexcoord_atlas.xy);
	normal_view = (normal_view - 0.5) * 2.0;

	vec4 N = normalize(normal_view);
	vec4 final = vec4(0.0);
	
	for(int i = 0; i < uCount; i++) //uCount = number of lights active in the scene
	{
		vec4 lightDirectionFull = uPointLightData[i].position - position; //used later to calculate distance from light
		vec4 L = normalize(lightDirectionFull);
		vec4 R = reflect(-L, N);

		float lightDistance = length(lightDirectionFull); 

		//float attenuation = clamp(uPointLightData[i].radiusSq / lightDistance, 0.0, 0.2);
		float attenuation = attenuation(lightDistance, dot(lightDistance, lightDistance), uPointLightData[i].radiusInv, uPointLightData[i].radiusInvSq);

		vec4 diffuse = max(dot(N, L), 0.0) * diffuseSample * uPointLightData[i].color; //applies texture and light color
		//vec4 specular = pow(max(dot(V, R), 0.0), specularPower) * uPointLightData[i].color; //specular color is the same as the light color
		

		final += attenuation * vec4(diffuse);
	}

	 rtFragColor = vec4(final);
	//Debug
	//rtFragColor = texture(uImage05, vTexcoord_atlas.xy);
	rtFragColor = normal_view;

	rtFragColor.a = diffuseSample.a;
}
