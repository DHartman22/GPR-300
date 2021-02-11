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
	
	passTangentBasis_transform_vs4x.glsl
	Calculate and pass tangent basis.
*/

#version 450

// ****TO-DO: 
//	-> declare matrices
//		(hint: not MVP this time, made up of multiple; see render code)
//	-> transform input position correctly, assign to output
//		(hint: this may be done in one or more steps)
//	-> declare attributes for lighting and shading
//		(hint: normal and texture coordinate locations are 2 and 8)
//	-> declare additional matrix for transforming normal
//	-> declare varyings for lighting and shading
//	-> calculate final normal and assign to varying
//	-> assign texture coordinate to varying

//Edited by Daniel Hartman and Nick Preis

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec2 aTexcoord;


flat out int vVertexID;
flat out int vInstanceID;

uniform mat4 uMV, uMV_nrm, uMVP;

out vec4 vNormal;
out vec4 vPosition;
out vec2 vTexcoord;

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position

	//done in class	
	vPosition = uMV * uMV_nrm * aPosition; //camera space
	vNormal = uMV_nrm * vec4(aNormal, 0.0); //object space
	
	//passing texcoord so drawLambert/drawPhong can use textures
	vTexcoord = aTexcoord;
	
	
	gl_Position = uMVP * aPosition;


	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
