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
	
	drawGBuffers_fs4x.glsl
	Output g-buffers for use in future passes.
*/

#version 450

// ****TO-DO:
//	-> declare view-space varyings from vertex shader
//	-> declare MRT for pertinent surface data (incoming attribute info)
//		(hint: at least normal and texcoord are needed)
//	-> declare uniform samplers (at least normal map)
//	-> calculate final normal
//	-> output pertinent surface data

in vec4 vPosition;
in vec4 vNormal;
in vec4 vTexcoord;

uniform sampler2D uImage00; //diffuse
uniform sampler2D uImage01; //specular

uniform sampler2D uImage04; //scene texcoord
uniform sampler2D uImage05; //scene normals
uniform sampler2D uImage06; //scene "positions"
uniform sampler2D uImage07; //scene depth

uniform mat4 uPB_inv;

layout (location = 0) out vec4 rtTexcoord;
layout (location = 1) out vec4 rtNormal;
layout (location = 2) out vec4 rtDiffuse;
layout (location = 3) out vec4 rtPosition;


void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
	rtTexcoord = vTexcoord;

	//ensures that vNormal fits in the color range
	rtNormal = vec4(normalize(vNormal.xyz) * 0.5 + 0.5, 1.0);
	rtDiffuse = texture(uImage00, vTexcoord.xy);
	rtDiffuse.a = texture(uImage01, vTexcoord.xy).r;
	rtPosition = texture(uImage05, vTexcoord.xy) * vPosition;
	//rtPosition = vPosition;
}
