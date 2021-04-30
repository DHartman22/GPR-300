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
	
	a3_DemoMode4_Animate-idle-update.c
	Demo mode implementations: animation scene.

	********************************************
	*** UPDATE FOR ANIMATION SCENE MODE      ***
	********************************************
*/

//Edited by Daniel Hartman and Nick Preis
//-----------------------------------------------------------------------------

#include "../a3_DemoMode4_Animate.h"

//typedef struct a3_DemoState a3_DemoState;
#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoMacros.h"


//-----------------------------------------------------------------------------

inline int a3animate_updateKeyframeController(a3_KeyframeController* keyCtrl,
	a3f32 const dt)
{
	if (keyCtrl)
	{
		// update timer
		keyCtrl->time += dt;
		if (keyCtrl->time >= keyCtrl->duration)
		{
			keyCtrl->time -= keyCtrl->duration;
			keyCtrl->index = (keyCtrl->index + 1) % keyCtrl->count;
		}
		keyCtrl->param = keyCtrl->time * keyCtrl->durationInv;

		// done
		return 1;
	}
	return -1;
}

inline int a3animate_updateSkeletonLocalSpace(a3_Hierarchy const* hierarchy,
	a3mat4* localSpaceArray,
	a3_SceneObjectData const keyPoseArray[animateMaxCount_skeletonPose][animateMaxCount_skeletonJoint],
	a3_KeyframeController const* keyCtrl)
{
	if (hierarchy && localSpaceArray && keyPoseArray && keyCtrl)
	{
		a3ui32 j;
		a3ui32 const i0 = keyCtrl->index, i1 = (i0 + 1) % keyCtrl->count;
		a3f32 u = keyCtrl->param;
		a3_SceneObjectData const* p0 = keyPoseArray[i0 + 1], * p1 = keyPoseArray[i1 + 1], * pBase = keyPoseArray[0];
		a3_SceneObjectData tmpPose;
		
		for (j = 0;
			j < hierarchy->numNodes;
			++j, ++p0, ++p1, ++pBase)
		{
			// testing: copy base pose
			tmpPose = *pBase;

			//offset the base pose's local position and rotation so it can interpolate through the target points while retaining the base pose
			// ****DONE:
			// interpolate channels

			//helpful resource that I used to remember the templates for each matrix
			//https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/SpatialTransformationMatrices.html

			a3vec3 offsetTranslation;

			offsetTranslation.x = a3lerpFunc(p0->position.x, p1->position.x, u);
			offsetTranslation.y = a3lerpFunc(p0->position.y, p1->position.y, u);
			offsetTranslation.z = a3lerpFunc(p0->position.z, p1->position.z, u);

			a3vec3 offsetRotation;

			offsetRotation.x = a3lerpFunc(p0->euler.x, p1->euler.x, u);
			offsetRotation.y = a3lerpFunc(p0->euler.y, p1->euler.y, u);
			offsetRotation.z = a3lerpFunc(p0->euler.z, p1->euler.z, u);

			a3vec3 lerpScale;

			lerpScale.x = a3lerpFunc(p0->scale.x, p1->scale.x, u);
			lerpScale.y = a3lerpFunc(p0->scale.y, p1->scale.y, u);
			lerpScale.z = a3lerpFunc(p0->scale.z, p1->scale.z, u);

			// ****DONE:
			// concatenate base pose
			
			// ****DONE: 
			// convert to matrix

			//tmpPose = skeleton pose
			a3mat4 translationMat = {
				1.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 1.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				tmpPose.position.x + offsetTranslation.x, tmpPose.position.y + offsetTranslation.y, tmpPose.position.z + offsetTranslation.z, 1.0f
			};

			a3mat4 xRotationMat = {
				1.0f, 0.0f, 0.0f, 0.0f,
				0.0f, a3cosd(tmpPose.euler.x + offsetRotation.x), a3sind(tmpPose.euler.x + offsetRotation.x), 0.0f,
				0.0f, -a3sind(tmpPose.euler.x + offsetRotation.x), a3cosd(tmpPose.euler.x + offsetRotation.x), 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
			};

			a3mat4 yRotationMat = {
				a3cosd(tmpPose.euler.y + offsetRotation.y), 0.0f, -a3sind(tmpPose.euler.y + offsetRotation.y), 0.0f,
				0.0f, 1.0f, 0.0f, 0.0f,
				a3sind(tmpPose.euler.y + offsetRotation.y), 0.0f, a3cosd(tmpPose.euler.y + offsetRotation.y), 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
			};

			a3mat4 zRotationMat = {
				a3cosd(tmpPose.euler.z + offsetRotation.z), -a3sind(tmpPose.euler.z + offsetRotation.z), 0.0f, 0.0f,
				a3sind(tmpPose.euler.z + offsetRotation.z), a3cosd(tmpPose.euler.z + offsetRotation.z), 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
			};

			//nodes are not individually scaled (all set to 1), so offsetting the scale is unnecessary
			a3mat4 scaleMat = {
				lerpScale.x, 0.0f, 0.0f, 0.0f,
				0.0f, lerpScale.y, 0.0f, 0.0f,
				0.0f, 0.0f, lerpScale.z, 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
			};

			a3mat4 finalMat = translationMat; //start with the translation matrix

			//concatenate rotation and scale onto final mat
			a3real4x4Concat(xRotationMat.m, finalMat.m);
			a3real4x4Concat(yRotationMat.m, finalMat.m);
			a3real4x4Concat(zRotationMat.m, finalMat.m);
			a3real4x4Concat(scaleMat.m, finalMat.m);

			localSpaceArray[j] = finalMat;
		}

		// done
		return 1;
	}
	return -1;
}

inline int a3animate_updateSkeletonObjectSpace(a3_Hierarchy const* hierarchy,
	a3mat4* const objectSpaceArray, a3mat4 const* const localSpaceArray)
{
	if (hierarchy && objectSpaceArray && localSpaceArray)
	{
		// ****DONE: 
		// forward kinematics
		a3ui32 j = 0;
		for (j = 0; j < hierarchy->numNodes; j++)
		{
			if (j == 0)
			{
				// used SolveOrderedFK pseudocode from slides for solution
				//same value, root local space IS root world space
				objectSpaceArray[j] = localSpaceArray[j];
			}
			else
			{
				// needed to use temp to apply concated value to objectSpaceArray 
				a3mat4 temp = localSpaceArray[j];
				//child world transform = parent world transform * child local transform
				a3real4x4Concat(objectSpaceArray[hierarchy->nodes[j].parentIndex].m, temp.m);
				objectSpaceArray[j] = temp;
			}
		}
		return 1;
	}
	return -1;
}

inline int a3animate_updateSkeletonRenderMats(a3_Hierarchy const* hierarchy,
	a3mat4* renderArray, a3mat4* renderAxesArray, a3mat4 const* objectSpaceArray, a3mat4 const mvp_obj)
{
	if (hierarchy && renderArray && objectSpaceArray)
	{
		a3real3rk up;
		a3ui32 j;
		a3i32 jp;
		for (j = 0;
			j < hierarchy->numNodes;
			++j)
		{
			jp = hierarchy->nodes[j].parentIndex;
			if (jp >= 0)
			{
				renderArray[j] = a3mat4_identity;
				a3real3Diff(renderArray[j].m[2], objectSpaceArray[j].m[3], objectSpaceArray[jp].m[3]);
				up = (renderArray[j].m20 * renderArray[j].m21) ? a3vec3_z.v : a3vec3_y.v;
				a3real3MulS(a3real3CrossUnit(renderArray[j].m[0], up, renderArray[j].m[2]), 0.25f);
				a3real3MulS(a3real3CrossUnit(renderArray[j].m[1], renderArray[j].m[2], renderArray[j].m[0]), 0.25f);
				renderArray[j].v3 = objectSpaceArray[jp].v3;
			}
			else
			{
				// zero scale at root position
				a3real4x4SetScale(renderArray[j].m, 0.0f);
				renderArray[j].v3 = objectSpaceArray[j].v3;
			}
			a3real4x4Concat(mvp_obj.m, renderArray[j].m);

			// for joint axes rendering
			a3real4x4SetScale(renderAxesArray[j].m, 0.25f);
			a3real4x4Concat(objectSpaceArray[j].m, renderAxesArray[j].m);
			a3real4x4Concat(mvp_obj.m, renderAxesArray[j].m);
		}

		// done
		return 1;
	}
	return -1;
}


//-----------------------------------------------------------------------------
// UPDATE

void a3animate_update_graphics(a3_DemoState* demoState, a3_DemoMode4_Animate* demoMode)
{
	a3bufferRefillOffset(demoState->ubo_transform, 0, 0, sizeof(demoMode->modelMatrixStack), demoMode->modelMatrixStack);
	a3bufferRefillOffset(demoState->ubo_light, 0, 0, sizeof(demoMode->pointLightData), demoMode->pointLightData);
	a3bufferRefillOffset(demoState->ubo_mvp, 0, 0, sizeof(demoMode->skeletonPose_render), demoMode->skeletonPose_render);
	a3bufferRefillOffset(demoState->ubo_mvp, 0, sizeof(demoMode->skeletonPose_render), sizeof(demoMode->hierarchyDepth_skel), demoMode->hierarchyDepth_skel);
	a3bufferRefillOffset(demoState->ubo_mvp + 1, 0, 0, sizeof(demoMode->skeletonPose_renderAxes), demoMode->skeletonPose_renderAxes);
}

void a3animate_update_animation(a3_DemoState* demoState, a3_DemoMode4_Animate* demoMode, a3f64 const dt)
{
	if (demoState->updateAnimation)
	{


		// keyframe controllers
		a3f32 const dt_flt = (a3f32)dt;
		a3animate_updateKeyframeController(demoMode->animMorphTeapot, dt_flt);
		a3animate_updateKeyframeController(demoMode->animPoseSkel, dt_flt);

		// skeletal poses and matrices
		a3animate_updateSkeletonLocalSpace(demoMode->hierarchy_skel,
			demoMode->skeletonPose_local, demoMode->skeletonPose, demoMode->animPoseSkel);
		a3animate_updateSkeletonObjectSpace(demoMode->hierarchy_skel,
			demoMode->skeletonPose_object, demoMode->skeletonPose_local);

		//a3real2CatmullRom()
		
		// this is basically copied over directly from demomode 3 curve idle update

		//a3_SceneObjectData* sceneObjectData = demoMode->obj_camera_main->dataPtr;
		//
		//// teapot follows curved path
		//a3ui32 const i0 = demoMode->curveFinalSegmentIndex,
		//	i1 = (i0 + 1) % demoMode->curveFinalWaypointCount,
		//	iN = (i1 + 1) % demoMode->curveFinalWaypointCount,
		//	iP = (i0 + demoMode->curveFinalWaypointCount - 1) % demoMode->curveFinalWaypointCount;
		//
		////a3real3Lerp(sceneObjectData->position.v,
		////	demoMode->curveWaypoint[i0].v,
		////	demoMode->curveWaypoint[i1].v,
		////	demoMode->curveSegmentParam);
		//a3real3CatmullRom(sceneObjectData->position.v,
		//	demoMode->curveFinalWaypoint[iP].v,
		//	demoMode->curveFinalWaypoint[i0].v,
		//	demoMode->curveFinalWaypoint[i1].v,
		//	demoMode->curveFinalWaypoint[iN].v,
		//	demoMode->curveFinalSegmentParam);
		////a3real3HermiteTangent(sceneObjectData->position.v,
		////	demoMode->curveWaypoint[i0].v,
		////	demoMode->curveTangent[i0].v,
		////	demoMode->curveWaypoint[i1].v,
		////	demoMode->curveTangent[i1].v,
		////	demoMode->curveSegmentParam);

		//// update timer
		//demoMode->curveFinalSegmentTime += (a3f32)dt;
		//if (demoMode->curveFinalSegmentTime >= demoMode->curveFinalSegmentDuration)
		//{
		//	demoMode->curveFinalSegmentTime -= demoMode->curveFinalSegmentDuration;
		//	demoMode->curveFinalSegmentIndex = (demoMode->curveFinalSegmentIndex + 1) % demoMode->curveFinalWaypointCount;
		//}
		//demoMode->curveFinalSegmentParam = demoMode->curveFinalSegmentTime * demoMode->curveFinalSegmentDurationInv;

	}

	// always update render data
	a3animate_updateSkeletonRenderMats(demoMode->hierarchy_skel,
		demoMode->skeletonPose_render, demoMode->skeletonPose_renderAxes, demoMode->skeletonPose_object,
		demoMode->obj_skeleton->modelMatrixStackPtr->modelViewProjectionMat);
}

void a3animate_update_scene(a3_DemoState* demoState, a3_DemoMode4_Animate* demoMode, a3f64 const dt)
{
	void a3demo_update_defaultAnimation(a3f64 const dt, a3_SceneObjectComponent const* sceneObjectArray,
		a3ui32 const count, a3ui32 const axis, a3boolean const updateAnimation);
	void a3demo_update_bindSkybox(a3_SceneObjectComponent const* sceneObject_skybox,
		a3_ProjectorComponent const* projector_active);

	const a3mat4 bias = {
		0.5f, 0.0f, 0.0f, 0.0f,
		0.0f, 0.5f, 0.0f, 0.0f,
		0.0f, 0.0f, 0.5f, 0.0f,
		0.5f, 0.5f, 0.5f, 1.0f
	}, biasInv = {
		2.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 2.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 2.0f, 0.0f,
		-1.0f, -1.0f, -1.0f, 1.0f
	};

	a3_ProjectorComponent* projector = demoMode->proj_camera_main;

	a3_PointLightData* pointLightData;
	a3ui32 i;

	// update camera
	a3demo_updateSceneObject(demoMode->obj_camera_main, 1);
	a3demo_updateSceneObjectStack(demoMode->obj_camera_main, projector);
	a3demo_updateProjector(projector);
	a3demo_updateProjectorViewMats(projector);
	a3demo_updateProjectorBiasMats(projector, bias, biasInv);

	// update light
	a3demo_updateSceneObject(demoMode->obj_light_main, 1);
	a3demo_updateSceneObjectStack(demoMode->obj_light_main, projector);

	// update skybox
	a3demo_updateSceneObject(demoMode->obj_skybox, 0);
	a3demo_update_bindSkybox(demoMode->obj_skybox, projector);
	a3demo_updateSceneObjectStack(demoMode->obj_skybox, projector);

	// update scene objects
	a3demo_update_defaultAnimation((dt * 15.0), demoMode->obj_teapot,
		(a3ui32)(demoMode->obj_ground - demoMode->obj_teapot), 2, demoState->updateAnimation);

	a3demo_updateSceneObject(demoMode->obj_skeleton, 0);
	a3demo_updateSceneObjectStack(demoMode->obj_skeleton, projector);

	a3demo_updateSceneObject(demoMode->obj_teapot, 0);
	a3demo_updateSceneObjectStack(demoMode->obj_teapot, projector);

	a3demo_updateSceneObject(demoMode->obj_ground, 0);
	a3demo_updateSceneObjectStack(demoMode->obj_ground, projector);

	// update light positions and transforms
	for (i = 0, pointLightData = demoMode->pointLightData;
		i < animateMaxCount_pointLight;
		++i, ++pointLightData)
	{
		a3real4Real4x4Product(pointLightData->position.v,
			projector->sceneObjectPtr->modelMatrixStackPtr->modelMatInverse.m,
			pointLightData->worldPos.v);
	}
}

void a3animate_update(a3_DemoState* demoState, a3_DemoMode4_Animate* demoMode, a3f64 const dt)
{
	// update scene objects and related data
	a3animate_update_scene(demoState, demoMode, dt);

	// specific object animation
	a3animate_update_animation(demoState, demoMode, dt);

	// prepare and upload graphics data
	a3animate_update_graphics(demoState, demoMode);
}


//-----------------------------------------------------------------------------
