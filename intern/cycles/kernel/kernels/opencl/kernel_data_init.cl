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

#include "split/kernel_data_init.h"

__kernel void kernel_ocl_path_trace_data_init(
        KernelGlobals *kg,
        ccl_constant KernelData *data,
        ccl_global void *split_data_buffer,
        int num_elements,
        ccl_global char *ray_state,
        ccl_global uint *rng_state,

#define KERNEL_TEX(type, ttype, name)                                   \
        ccl_global type *name,
#include "../../kernel_textures.h"

        int start_sample,
        int end_sample,
        int sx, int sy, int sw, int sh, int offset, int stride,
        int rng_state_offset_x,
        int rng_state_offset_y,
        int rng_state_stride,
        ccl_global int *Queue_index,                 /* Tracks the number of elements in queues */
        int queuesize,                               /* size (capacity) of the queue */
        ccl_global char *use_queues_flag,            /* flag to decide if scene-intersect kernel should use queues to fetch ray index */
#ifdef __WORK_STEALING__
        ccl_global unsigned int *work_pool_wgs,      /* Work pool for each work group */
        unsigned int num_samples,                    /* Total number of samples per pixel */
#endif
        int parallel_samples,                        /* Number of samples to be processed in parallel */
        int buffer_offset_x,
        int buffer_offset_y,
        int buffer_stride,
        ccl_global float *buffer)
{
	kernel_data_init(kg,
	                 data,
	                 split_data_buffer,
	                 num_elements,
	                 ray_state,
	                 rng_state,

#define KERNEL_TEX(type, ttype, name) name,
#include "../../kernel_textures.h"

	                 start_sample,
	                 end_sample,
	                 sx, sy, sw, sh, offset, stride,
	                 rng_state_offset_x,
	                 rng_state_offset_y,
	                 rng_state_stride,
	                 Queue_index,
	                 queuesize,
	                 use_queues_flag,
#ifdef __WORK_STEALING__
	                 work_pool_wgs,
	                 num_samples,
#endif
	                 parallel_samples,
	                 buffer_offset_x,
	                 buffer_offset_y,
	                 buffer_stride,
	                 buffer);
}
