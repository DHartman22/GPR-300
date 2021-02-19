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
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/

#version 450

// ****TO-DO:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

layout (location = 0) out vec4 rtFragColor;

uniform int uCount;

in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;
in vec4 vView;

in vec4 vLightPos;
in vec4 vLightColor;
in float vLightRadii;

uniform vec4 uLightPos;
uniform vec4 uLightColor;
uniform float uLightRadii;
uniform vec4 uColor;
uniform sampler2D uSampler;



void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);

		//mostly done in class
	vec4 N = normalize(vNormal);
	vec4 L = normalize(vLightPos - vPosition);
	vec4 V = normalize(vView);

	vec4 R = reflect(-L, N);


	float kd = max(dot(N, L), 0.0);
	vec3 diffuse = kd * vec3(texture2D(uSampler, vTexcoord));
	vec3 specular = pow(max(dot(R, V), 0.0), 2048.0) * vec3(vLightColor);

	//kd = max(kd, 0.0);
	rtFragColor = vec4(diffuse + specular, 1.0);
	//rtFragColor = kd * uLightRadii * uLightColor * texture2D(uSampler, vTexcoord) * uColor;
}
