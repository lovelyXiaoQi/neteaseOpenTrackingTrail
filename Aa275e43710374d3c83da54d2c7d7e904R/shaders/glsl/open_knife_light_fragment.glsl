// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.
precision highp float;


#include "uniformExtraVectorConstants.h"
#include "fragmentVersionCentroidUV.h"
#include "uniformEntityConstants.h"
#include "uniformPerFrameConstants.h"


#include "uniformShaderConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

varying vec4 light;
varying vec4 fogColor;


void main()
{

	float last_progress = float(int(EXTRA_VECTOR1.w))*0.01f;

	float target_progress = EXTRA_VECTOR1.w-float(int(EXTRA_VECTOR1.w));

	vec4 color = texture2D(TEXTURE_0, vec2(1.f-uv.x, mix(last_progress, target_progress, uv.y)));

	if (color.a <= 0.f){
		discard;
	}

	highp vec4 start_color = vec4(abs(EXTRA_VECTOR1.x-float(int(EXTRA_VECTOR1.x*1000.f))*0.001f)*10000.f, abs(EXTRA_VECTOR1.y-float(int(EXTRA_VECTOR1.y*1000.f))*0.001f)*10000.f, abs(EXTRA_VECTOR1.z-float(int(EXTRA_VECTOR1.z*1000.f))*0.001f)*10000.f, abs(EXTRA_VECTOR3.x-float(int(EXTRA_VECTOR3.x*1000.f))*0.001f)*10000.f);

	highp vec4 end_color = vec4(abs(EXTRA_VECTOR2.x-float(int(EXTRA_VECTOR2.x*1000.f))*0.001f)*10000.f, abs(EXTRA_VECTOR2.y-float(int(EXTRA_VECTOR2.y*1000.f))*0.001f)*10000.f, abs(EXTRA_VECTOR2.z-float(int(EXTRA_VECTOR2.z*1000.f))*0.001f)*10000.f, abs(EXTRA_VECTOR3.y-float(int(EXTRA_VECTOR3.y*1000.f))*0.001f)*10000.f);
	
	color.rgb *= mix(end_color.rgb, start_color.rgb, mix(last_progress, target_progress, uv.y));

	#ifdef BLOOM
		color.a = 0.05f;
	#else
		color.a *= mix(end_color.a, start_color.a, mix(last_progress, target_progress, uv.y));
	#endif
	
	gl_FragColor = color;
}
