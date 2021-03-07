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


in vec4 vTexcoord_atlas;

uniform int uCount;

uniform sampler2D uImage00; //diffuse
uniform sampler2D uImage01; //specular

uniform sampler2D uImage04; //scene texcoord
uniform sampler2D uImage05; //scene normals
uniform sampler2D uImage06; //scene "positions"
uniform sampler2D uImage07; //scene depth


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
	vec4 normal = texture(uImage05, sceneTexcoord.xy);
	float specularPower = 32.0f;



	 rtFragColor = diffuseSample;
	//Debug
	//rtFragColor = texture(uImage05, vTexcoord_atlas.xy);
}
