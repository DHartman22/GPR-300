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
	
	postBlend_fs4x.glsl
	Blending layers, composition.
*/
//Edited by Daniel Hartman and Nick Preis

#version 450

// ****DONE: (incomplete)
//	-> declare texture coordinate varying and set of input textures
//	-> implement some sort of blending algorithm that highlights bright areas
//		(hint: research some Photoshop blend modes)

layout (location = 0) out vec4 rtFragColor;

in vec2 vTexcoord;

uniform sampler2D uSampler1;
uniform sampler2D uSampler2;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE PURPLE
	//rtFragColor = vec4(0.5, 0.0, 1.0, 1.0);

	//Process found on this website: https://distrustsimplicity.net/articles/texture-blending-in-glsl/
	vec4 textureColor = texture(uSampler1, vTexcoord);
	textureColor += texture(uSampler2, vTexcoord);
	rtFragColor = textureColor;
}
