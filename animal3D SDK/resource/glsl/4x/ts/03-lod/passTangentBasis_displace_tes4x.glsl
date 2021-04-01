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
	
	passTangentBasis_displace_tes4x.glsl
	Pass interpolated and displaced tangent basis.
*/

//Edited by Nick Preis and Daniel Hartman

#version 450

// ****TO-DO: 
//	-> declare inbound and outbound varyings to pass along vertex data
//		(hint: inbound matches TCS naming and is still an array)
//		(hint: outbound matches GS/FS naming and is singular)
//	-> copy varying data from input to output
//	-> displace surface along normal using height map, project result
//		(hint: start by testing a "pass-thru" shader that only copies 
//		gl_Position from the previous stage to get the hang of it)

layout (triangles, equal_spacing) in;

uniform sampler2D uTex_nm, uTex_hm;
uniform mat4 uP;
uniform mat4 uMVP;

const float displacementDepth = 0.0f;

in vbVertexData_tess {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData_tess[]; 

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

void main()
{
	// gl_TessCoord -> barycentric (3 elements)

	vec4 tc0 = mix(gl_in[0].gl_Position, vVertexData_tess[0].vTexcoord_atlas, gl_TessCoord.x);
	vec4 tc1 = mix(gl_in[1].gl_Position, vVertexData_tess[1].vTexcoord_atlas, gl_TessCoord.y);
	vec4 tc2 = mix(gl_in[2].gl_Position, vVertexData_tess[2].vTexcoord_atlas, gl_TessCoord.z);

	vec4 p0 = mix(gl_in[0].gl_Position, vVertexData_tess[0].vTexcoord_atlas, gl_TessCoord.x);

	vec4 sample_nm = texture(uTex_nm, vVertexData_tess[0].vTexcoord_atlas.xy);

	p0.y += texture(uTex_hm, tc0.xy).r * displacementDepth;
	vTangentBasis_view[0] += (texture(uTex_hm, tc0.xy).r * displacementDepth) ;

	vec4 p1 = mix(gl_in[1].gl_Position, vVertexData_tess[1].vTexcoord_atlas, gl_TessCoord.y);
	vTangentBasis_view[1] += ((texture(uTex_hm, tc1.xy).r * displacementDepth) * normalize(sample_nm));
	p1.y += texture(uTex_hm, tc1.xy).r * displacementDepth;

	vec4 p2 = mix(gl_in[2].gl_Position, vVertexData_tess[2].vTexcoord_atlas, gl_TessCoord.z);
	vTangentBasis_view[2] += (texture(uTex_hm, tc2.xy).r * displacementDepth);
	p2.y += texture(uTex_hm, tc2.xy).r * displacementDepth;

	//tbn mat experiment

	vec4 tan_view = normalize(vTangentBasis_view[0]);
	vec4 bit_view = normalize(vTangentBasis_view[1]);
	vec4 nrm_view = normalize(vTangentBasis_view[2]);
	vec4 pos_view = vTangentBasis_view[3];
	
	// view-space view vector
	//vec4 viewVec = normalize(kEyePos - pos_view);
	
	// ****TO-DO:
	//	-> convert view vector into tangent space
	//		(hint: the above TBN bases convert tangent to view, figure out 
	//		an efficient way of representing the required matrix operation)
	// tangent-space view vector
	vec3 viewVec_tan = vec3(
		tan_view.x,
		tan_view.y,
		tan_view.z
	);

	mat4 tbn = {tan_view, bit_view, nrm_view, pos_view}; //create matrix manually so I can inverse it

	gl_Position = uP * vTangentBasis_view * (p0); // what do I do here?


}
