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
uniform vec2 uAxis;

//Blur formula found in the blue book, pages 487 and 488
//Weights directly taken from blue book
const float weights[] = float[](0.0024499299678342,
0.0043538453346397,
0.0073599963704157,
0.0118349786570722,
0.0181026699707781,
0.0263392293891488,
0.0364543006660986,
0.0479932050577658,
0.0601029809166942,
0.0715974486241365,
0.0811305381519717,
0.0874493212267511,
0.0896631113333857,
0.0874493212267511,
0.0811305381519717,
0.0715974486241365,
0.0601029809166942,
0.0479932050577658,
0.0364543006660986,
0.0263392293891488,
0.0181026699707781,
0.0118349786570722,
0.0073599963704157,
0.0043538453346397,
0.0024499299678342);

void main() //this is mostly ported code from the blue book
{

	//vec2 offsetTexcoord = vTexcoord * uAxis;
	//rtFragColor = texture(uTex_dm, vTexcoord);
	vec4 color = vec4(0.0);

	int i = 0;

	bool isHorizontal = false;

	ivec2 iterator;
	vec2 fullAxis = 1/uAxis;
	if(uAxis.x > 0)
	{
		isHorizontal = true;
	}

	ivec2 pixel = ivec2(gl_FragCoord);

	
	if(isHorizontal)
	{
		for(i = 0; i < weights.length(); i++)
		{
	// color accumulates
	// current coord + offset coord
	// samples 25 times
			color += texelFetch(uTex_dm, pixel + ivec2(i, 0), 0) * weights[i]; 
		}
	}
	else
	{
		for(i = 0; i < weights.length(); i++)
		{
	// color accumulates
	// current coord + offset coord
	// samples 25 times
			color += texelFetch(uTex_dm, pixel + ivec2(0, i), 0) * weights[i]; 
		}
	}

	
	

	// temp vec2 current coord, 
	//  -> offset coord???
	//		vec2 for offset: ???
	//			e.g. horizontal: vec2(1 / img width, 0)
	//			e.g. vertical: vec2(0, 1/ img height)

	//for some reason, the output is drawing in a weird way, but the blur itself is working.
	//Additionally, the image seems to shift itself with every blur pass, and I think it has something to do with
	//the ivec2 pixel variable, but I couldn't figure out what to make it
	rtFragColor = color;
	//rtFragColor = vec4(1.0, 0.0, 0.0, 1.0);

}