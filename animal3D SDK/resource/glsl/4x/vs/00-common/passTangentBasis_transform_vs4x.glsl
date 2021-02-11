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

// Edited by Daniel Hartman

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec2 aTexcoord;


flat out int vVertexID;
flat out int vInstanceID;

uniform mat4 uMV, uP, uMV_nrm;

out mat3 vTBN;

out vec3 vTangent;
out vec3 vBitangent;

out vec4 vNormal;
out vec4 vPosition;

out vec3 vLightPos;
out vec4 vLightColor;

out vbVertexData {
	vec3 normal;
	vec3 tangent;
	vec3 bitangent;
} vb_vertex_data;

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;

	//TEXCOORD IS UV!
	//P = vPosition
	//U = TEXCOORD.X
	//V = TEXCOORD.Y
	//uMV_nrm = changep1?
	//vec4(aNormal, 0.0) = changep2?

	vPosition = uMV * uMV_nrm * aPosition; //camera space
	vNormal = uMV_nrm * vec4(aNormal, 0.0); //object space

	vPosition = aPosition;
	vNormal = vec4(aNormal, 0.0);
	
	vTangent = vec3(aTexcoord.xy, 0.0); //use texcoord as tangent

	//adapted from the blue book pg 631
	vTangent = normalize(mat3(uMV) * vTangent); 
	vBitangent = cross(vec3(vNormal), vTangent);


	vBitangent = vec3(0.0, aTexcoord.y, 0.0);


	//https://champlain.instructure.com/courses/1623294/files/175356519?module_item_id=76564417


	gl_Position = vPosition;


	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
