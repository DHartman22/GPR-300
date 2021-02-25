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

void main()
{

	
	vec3 textureColor = vec3(texture(uTex_dm, vTexcoord)); //gets color at texcoord

	vec3 luminance = vec3(0.299, 0.587, 0.144);
	//Luminance function from blue book, page 486

	float Y = dot(textureColor, luminance);
	
	textureColor = textureColor * 4.0 * smoothstep(0.4, 1.0, Y);

	rtFragColor = vec4(textureColor, 1.0);

}
