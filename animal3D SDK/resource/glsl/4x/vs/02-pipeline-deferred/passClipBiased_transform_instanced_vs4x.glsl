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
	
	passClipBiased_transform_instanced_vs4x.glsl
	Calculate and biased clip coordinate with instancing.
*/

#version 450

#define MAX_INSTANCES 1024

// ****TO-DO: 
//	-> declare uniform block containing MVP for all lights
//	-> calculate final clip-space position
//	-> declare varying for biased clip-space position
//	-> calculate and copy biased clip to varying
//		(hint: bias matrix is provided as a constant)

layout (location = 0) in vec4 aPosition;

flat out int vVertexID;
flat out int vInstanceID; //light index

// bias matrix
const mat4 bias = mat4(
	0.5, 0.0, 0.0, 0.0,
	0.0, 0.5, 0.0, 0.0,
	0.0, 0.0, 0.5, 0.0,
	0.5, 0.5, 0.5, 1.0
);



uniform ubMVP
{
	mat4 sLightMVP[MAX_INSTANCES];
};

out vec4 vPosition_biased_clip;

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position

	gl_Position = sLightMVP[vInstanceID] * aPosition;
	//gl_Position = aPosition * sLightMVP[vInstanceID];

	vPosition_biased_clip = bias * sLightMVP[vInstanceID] * aPosition;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
