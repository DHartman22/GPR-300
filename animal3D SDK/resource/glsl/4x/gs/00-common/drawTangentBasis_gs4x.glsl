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

#version 450

// ****TO-DO: 
//	-> declare varying data to read from vertex shader
//		(hint: it's an array this time, one per vertex in primitive)
//	-> use vertex data to generate lines that highlight the input triangle
//		-> wireframe: one at each corner, then one more at the first corner to close the loop
//		-> vertex tangents: for each corner, new vertex at corner and another extending away 
//			from it in the direction of each basis (tangent, bitangent, normal)
//		-> face tangents: ditto but at the center of the face; need to calculate new bases
//	-> call "EmitVertex" whenever you're done with a vertex
//		(hint: every vertex needs gl_Position set)
//	-> call "EndPrimitive" to finish a new line and restart
//	-> experiment with different geometry effects

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 to 8 wireframe verts = 28 to 32 verts)
#define MAX_VERTICES 32

//credit for this file: https://www.geeks3d.com/hacklab/20180514/demo-wireframe-shader-opengl-3-2-and-opengl-es-3-1/

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

uniform mat4 uMVP;
uniform vec2 vScale;
out vec3 dist;

void main()
{
	//drawWireFrame();
	
	vColor = vec4(1.0, 0.0, 0.0, 1.0);

	//gets the position of each corner of a triangle
	vec4 pos0 = gl_in[0].gl_Position;
	vec4 pos1 = gl_in[1].gl_Position;
	vec4 pos2 = gl_in[2].gl_Position;

	//Makes position relative to mvp
	pos0 *= uMVP;
	pos1 *= uMVP;
	pos2 *= uMVP;

	//Converts positions into 2D
	vec2 pos0_2d = pos0.xy / pos0.w;
	vec2 pos1_2d = pos1.xy / pos1.w;
	vec2 pos2_2d = pos2.xy / pos2.w;

	// This is where we start doing calculations of the vertices,
	// and area of the triangles

	// Calculations for position 0:
	//	Vectors:
	vec2 v1_0 = vScale * (pos1_2d - pos0_2d);
	vec2 v2_0 = vScale * (pos2_2d - pos0_2d);

	// Area:
	float a0 = abs((v1_0.x * v2_0.y) - (v1_0.y * v2_0.x));

	// Distance from vertex to line:
	float d0 = a0 / length(v1_0 - v2_0);
	dist = vec3(d0, 0.0, 0.0);
	dist *= pos0.w;

	gl_Position = pos0;

	EmitVertex();


	// Calculations for position 1:
	//	Vectors:
	vec2 v0_1 = vScale * (pos0_2d - pos1_2d);
	vec2 v2_1 = vScale * (pos2_2d - pos1_2d);

	// Area:
	float a1 = abs((v0_1.x * v2_1.y) - (v0_1.y * v2_1.x));

	// Distance from vertex to line:
	float d1 = a1 / length(v0_1 - v2_1);
	dist = vec3(0.0, d1, 0.0);
	dist *= pos1.w;

	gl_Position = pos1;

	EmitVertex();


	// Calculations for position 2:
	//	Vectors:
	vec2 v0_2 = vScale * (pos0_2d - pos2_2d);
	vec2 v1_2 = vScale * (pos1_2d - pos2_2d);

	// Area:
	float a2 = abs((v0_2.x * v1_2.y) - (v0_2.y * v1_2.x));

	// Distance from vertex to line:
	float d2 = a2 / length(v1_2 - v1_2);
	dist = vec3(0.0, 0.0, d2);
	dist *= pos2.w;

	gl_Position = pos2;

	EmitVertex();

	EndPrimitive();
}
