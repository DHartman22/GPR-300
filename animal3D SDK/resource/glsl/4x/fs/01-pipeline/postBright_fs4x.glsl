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
	
	postBright_fs4x.glsl
	Bright pass filter.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and input texture
//	-> implement relative luminance function
//	-> implement simple "tone mapping" such that the brightest areas of the 
//		image are emphasized, and the darker areas get darker

layout (location = 0) out vec4 rtFragColor;
layout (binding = 0) uniform sampler2D uTex_dm;

in vec2 vTexcoord;
//uniform sampler2D uSampler;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);
	vec3 color = vec3(1.0, 0.5, 0.0);
	
	

	//Luminance function goes here
	vec3 greyScale = vec3(0.299, 0.587, 0.0722);

	float L = dot(color, greyScale);

	vec4 newColor = texelFetch(uTex_dm, ivec2(gl_FragCoord.xy), 0);

	newColor.rgb = vec3(1.0) - exp(-newColor.rgb * L);
	
	rtFragColor = newColor;
	//rtFragColor = vec4(L, L, L, 1.0);
	//rtFragColor = texture2D(uTex_dm, vTexcoord);
}
