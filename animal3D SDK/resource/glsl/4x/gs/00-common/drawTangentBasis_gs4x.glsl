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
	
	drawTangentBases_gs4x.glsl
	Draw tangent bases of vertices and/or faces, and/or wireframe shapes, 
		determined by flag passed to program.
*/
//Edited by Nick Preis and Daniel Hartman

#version 450

// ****TO-DO: 
//	-> declare varying data to read from vertex shader
//		(hint: it's an array this time, one per vertex in primitive)
//	-> use vertex data to generate lines that highlight the input triangle
//		-> wireframe: one at each corner, then one more at the first corner to close the loop (DONE)
//		-> vertex tangents: for each corner, new vertex at corner and another extending away 
//			from it in the direction of each basis (tangent, bitangent, normal)
//		-> face tangents: ditto but at the center of the face; need to calculate new bases
//	-> call "EmitVertex" whenever you're done with a vertex
//		(hint: every vertex needs gl_Position set)
//	-> call "EndPrimitive" to finish a new line and restart
//	-> experiment with different geometry effects

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 to 8 wireframe verts = 28 to 32 verts)
#define MAX_VERTICES 32

layout (triangles) in;

layout (line_strip, max_vertices = MAX_VERTICES) out;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData[];

out vec4 vColor;

void drawWireFrame()
{
	vColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	EndPrimitive();

	vColor = vec4(0.0, 1.0, 0.0, 1.0);
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	EndPrimitive();

	vColor = vec4(0.0, 0.0, 1.0, 1.0);
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	EndPrimitive();
}

void drawVertexTangents()
{
	// Calculating tangent, normal, and bitangent
	vec4 tangent = vVertexData[0].vTangentBasis_view[0];
	vec4 bitangent = vVertexData[0].vTangentBasis_view[1];
	vec4 normal = tangent * bitangent;

	mat4 TBN = mat4(
		tangent.x, bitangent.x, normal.x, 0.0,
		tangent.y, bitangent.y, normal.y, 0.0,
		tangent.z, bitangent.z, normal.z, 0.0,
		      0.0,         0.0,      0.0, 1.0
	);

	vColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position + TBN[0];
	EmitVertex();
	
	vColor = vec4(0.0, 1.0, 0.0, 1.0);
	gl_Position = gl_in[1].gl_Position + TBN[1];
	EmitVertex();
	
	vColor = vec4(0.0, 0.0, 1.0, 1.0);
	gl_Position = gl_in[2].gl_Position + TBN[2];
	EmitVertex();
	
	EndPrimitive();
}

void drawFaceTangents()
{
	// Calculating tangent, normal, and bitangent
	vec4 tangent = vVertexData[1].vTangentBasis_view[0];
	vec4 bitangent = vVertexData[1].vTangentBasis_view[1];
	vec4 normal = tangent * bitangent;

	mat4 TBN = mat4(
		tangent.x, bitangent.x, normal.x, 0.0,
		tangent.y, bitangent.y, normal.y, 0.0,
		tangent.z, bitangent.z, normal.z, 0.0,
		      0.0,         0.0,      0.0, 1.0
	);

	vColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position + TBN[0];
	EmitVertex();
	
	vColor = vec4(0.0, 1.0, 0.0, 1.0);
	gl_Position = gl_in[1].gl_Position + TBN[1];
	EmitVertex();
	
	vColor = vec4(0.0, 0.0, 1.0, 1.0);
	gl_Position = gl_in[2].gl_Position + TBN[2];
	EmitVertex();
	
	EndPrimitive();
}

void main()
{
	drawWireFrame();
	drawVertexTangents();
	//drawFaceTangents();
}
