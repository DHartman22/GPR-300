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
	
	passTangentBasis_morph_transform_vs4x.glsl
	Calculate and pass morphed tangent basis.
*/

#version 450

#define MAX_OBJECTS 128

// ****TO-DO: 
//	-> declare morph target attributes
//	-> declare and implement morph target interpolation algorithm
//	-> declare interpolation time/param/keyframe uniform
//	-> perform morph target interpolation using correct attributes
//		(hint: results can be stored in local variables named after the 
//		complete tangent basis attributes provided before any changes)

//layout (location = 0) in vec4 aPosition;
//layout (location = 2) in vec3 aNormal;
//layout (location = 8) in vec4 aTexcoord;
//layout (location = 10) in vec3 aTangent;
//layout (location = 11) in vec3 aBitangent;


// single morph target: position, normal, tangent
//		We can have 5 targets: 16 attributes / 3 per target
//		Leftover attribute: texcoord

// not morph target: texcoord, bitangent
//		texcoord is common attribute
//		bitengent is normal x tangent


struct sMorphTarget
{
	vec4 position;
	vec4 normal;
	vec4 tangent;
};

layout (location = 0) in sMorphTarget aMorphTarget[5];

layout (location = 15) in vec4 aTexcoord; //see demostate-load.c line 334 for proof its 15
//need texcoord

struct sModelMatrixStack
{
	mat4 modelMat;						// model matrix (object -> world)
	mat4 modelMatInverse;				// model inverse matrix (world -> object)
	mat4 modelMatInverseTranspose;		// model inverse-transpose matrix (object -> world skewed)
	mat4 modelViewMat;					// model-view matrix (object -> viewer)
	mat4 modelViewMatInverse;			// model-view inverse matrix (viewer -> object)
	mat4 modelViewMatInverseTranspose;	// model-view inverse transpose matrix (object -> viewer skewed)
	mat4 modelViewProjectionMat;		// model-view-projection matrix (object -> clip)
	mat4 atlasMat;						// atlas matrix (texture -> cell)
};

uniform ubTransformStack
{
	sModelMatrixStack uModelMatrixStack[MAX_OBJECTS];
};
uniform int uIndex;
uniform float uTime;

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

flat out int vVertexID;
flat out int vInstanceID;

//For slerp: https://www.geeks3d.com/20140205/glsl-simple-morph-target-animation-opengl-glslhacker-demo/
vec4 slerp(vec4 p0, vec4 p1, float t)
{
	float dotp = dot(normalize(p0), normalize(p1));
	if ((dotp > 0.9999) || (dotp<-0.9999))
	{
		if (t<=0.5)
		{
			return p0;
		}
		return p1;
	}
	float theta = acos(dotp * 3.14159/180.0);
	vec4 P = ((p0*sin((1-t)*theta) + p1*sin(t*theta)) / sin(theta));
	P.w = 1;
	return P;
}


void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;

	//Morph position of teapot based on time
	int pos1 = int(uTime) % 5;
	int pos2 = (pos1 + 1) % 5;
	float param = uTime - float(pos1);

	//Calculating tangent and normal slerp, then getting the cross product
	//Learned about cross product here: https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cross.xhtml
	vec3 aTangent = slerp(aMorphTarget[pos1].tangent, aMorphTarget[pos2].tangent, param).xyz;
	vec3 aNormal = slerp(aMorphTarget[pos1].normal, aMorphTarget[pos2].normal, param).xyz;
	vec3 aBitangent = cross(aTangent, aNormal);

	vec4 aPosition = slerp(aMorphTarget[pos1].position, aMorphTarget[pos2].position, param);
	

	sModelMatrixStack t = uModelMatrixStack[uIndex];
	
	vTangentBasis_view = t.modelViewMatInverseTranspose * mat4(aTangent, 0.0, aBitangent, 0.0, aNormal, 0.0, vec4(0.0));
	vTangentBasis_view[3] = t.modelViewMat * aPosition;
	gl_Position = t.modelViewProjectionMat * aPosition;
	
	
	vTexcoord_atlas = t.atlasMat * aTexcoord;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
