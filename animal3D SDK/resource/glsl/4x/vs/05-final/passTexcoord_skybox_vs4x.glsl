

#version 450

layout (location = 0) in vec4 aPosition;

flat out int vVertexID;
flat out int vInstanceID;

uniform mat4 uMVP;

out vec4 vTexcoord;


void main()
{

	vTexcoord = aPosition; //needs position since we're working with a cubemap

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;

	gl_Position = uMVP * aPosition;
}