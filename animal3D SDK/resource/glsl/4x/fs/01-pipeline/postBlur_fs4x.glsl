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
	
	postBlur_fs4x.glsl
	Gaussian blur.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and input texture
//	-> declare sampling axis uniform (see render code for clue)
//	-> declare Gaussian blur function that samples along one axis
//		(hint: the efficiency of this is described in class)

layout (location = 0) out vec4 rtFragColor;
layout (binding = 0) uniform sampler2D uTex_dm;

in vec2 vTexcoord;
//uniform sampler2D uTex_dm;
uniform vec2 uAxis;

void main()
{

	//vec2 offsetTexcoord = vTexcoord * uAxis;
	//rtFragColor = texture(uTex_dm, vTexcoord);
	rtFragColor = vec4(1.0, 0.0, 0.0, 1.0);


	// DUMMY OUTPUT: all fragments are OPAQUE AQUA
	// temp vec2 current coord, 
	//  -> offset coord???
	//		vec2 for offset: ???
	//			e.g. horizontal: vec2(1 / img width, 0)
	//			e.g. vertical: vec2(0, 1/ img height)

	// color accumulates

}
