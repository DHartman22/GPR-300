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

//Edited by Daniel Hartman and Nick Preis

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawColorUnif_fs4x.glsl
	Draw uniform solid color.
*/

#version 450

//Edited by Daniel Hartman and Nick Preis

// ****DONE: 
//	-> declare color uniform
//		(hint: correct name is used in codebase)
//	-> assign uniform directly to output

//use a3_DemoShaderProgram.h for variable names

uniform vec4 uColor; //difference between color and color0: one is a list the other is individual

layout (location = 0) out vec4 rtFragColor;

void main()
{
	rtFragColor = uColor;
}
