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
	
	postDeferredLightingComposite_fs4x.glsl
	Composite results of light pre-pass in deferred pipeline.
*/
//Edited by Daniel Hartman and Nick Preis

#version 450

// ****DONE:
//	-> declare samplers containing results of light pre-pass
//	-> declare samplers for texcoords, diffuse and specular maps
//	-> implement Phong sum with samples from the above
//		(hint: this entire shader is about sampling textures)

in vec4 vTexcoord_atlas;

layout (location = 0) out vec4 rtFragColor;

layout (binding = 8) uniform sampler2D rtDiffuseResult;
layout (binding = 9) uniform sampler2D rtSpecularResult;

uniform sampler2D uImage00; //diffuse texture
uniform sampler2D uImage01; //specular texture
uniform sampler2D uImage04; //scene texcoord

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE AQUA
	//rtFragColor = vec4(0.0, 1.0, 0.5, 1.0);
	//get samples of the relevant g-buffers
	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);

	//take the diffuse and specular results 
	vec4 diffuseResult = texture(rtDiffuseResult, sceneTexcoord.xy);
	vec4 specularResult = texture(rtSpecularResult, sceneTexcoord.xy);

	//should work in theory? but comes out wrong due to lightMVP being wrong...
	rtFragColor = (diffuseSample * diffuseResult) + (specularResult * specularSample);

	//ensures the skybox is visible fully
	rtFragColor.a = diffuseSample.a;

}
