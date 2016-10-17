/*
 * Copyright 2011-2015 Blender Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "split/kernel_shadow_blocked.h"

__kernel void kernel_ocl_path_trace_shadow_blocked(
        KernelGlobals *kg,
        ccl_constant KernelData *data)
{
	int lidx = get_local_id(1) * get_local_id(0) + get_local_id(0);

	ccl_local unsigned int ao_queue_length;
	ccl_local unsigned int dl_queue_length;
	if(lidx == 0) {
		ao_queue_length = split_params->queue_index[QUEUE_SHADOW_RAY_CAST_AO_RAYS];
		dl_queue_length = split_params->queue_index[QUEUE_SHADOW_RAY_CAST_DL_RAYS];
	}
	barrier(CLK_LOCAL_MEM_FENCE);

	/* flag determining if the current ray is to process shadow ray for AO or DL */
	char shadow_blocked_type = -1;

	int ray_index = QUEUE_EMPTY_SLOT;
	int thread_index = get_global_id(1) * get_global_size(0) + get_global_id(0);
	if(thread_index < ao_queue_length + dl_queue_length) {
		if(thread_index < ao_queue_length) {
			ray_index = get_ray_index(thread_index, QUEUE_SHADOW_RAY_CAST_AO_RAYS,
			                          split_state->queue_data, split_params->queue_size, 1);
			shadow_blocked_type = RAY_SHADOW_RAY_CAST_AO;
		} else {
			ray_index = get_ray_index(thread_index - ao_queue_length, QUEUE_SHADOW_RAY_CAST_DL_RAYS,
			                          split_state->queue_data, split_params->queue_size, 1);
			shadow_blocked_type = RAY_SHADOW_RAY_CAST_DL;
		}
	}

	if(ray_index == QUEUE_EMPTY_SLOT)
		return;

	kernel_shadow_blocked(kg,
	                      shadow_blocked_type,
	                      ray_index);
}
