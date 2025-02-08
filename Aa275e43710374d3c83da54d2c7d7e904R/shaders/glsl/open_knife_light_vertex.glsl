// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.
precision highp float;

#include "vertexVersionCentroidUV.h"
#include "uniformExtraVectorConstants.h"

#include "uniformWorldConstants.h"
#include "uniformEntityConstants.h"
#include "uniformPerFrameConstants.h"
#ifdef USE_SKINNING
#include "uniformAnimationConstants.h"
#endif

#line 13

attribute mediump vec4 POSITION;
attribute vec2 TEXCOORD_0;
attribute vec4 NORMAL;

#if defined(USE_SKINNING)
#ifdef MCPE_PLATFORM_NX
attribute uint BONEID_0;
#else
attribute float BONEID_0;
#endif
#endif

#ifdef COLOR_BASED
	attribute vec4 COLOR;
	varying vec4 vertColor;
#endif

varying vec4 light;
varying vec4 fogColor;

#ifdef USE_OVERLAY
	// When drawing horses on specific android devices, overlay color ends up being garbage data.
	// Changing overlay color to high precision appears to fix the issue on devices tested
	varying highp vec4 overlayColor;
#endif

#ifdef TINTED_ALPHA_TEST
	varying float alphaTestMultiplier;
#endif

#ifdef GLINT
	varying vec2 layer1UV;
	varying vec2 layer2UV;
	varying vec4 tileLightColor;
	varying vec4 glintColor;
#endif

#ifdef RNGL_LIGHT
uniform vec4 HIDE_COLOR;
#endif


const float AMBIENT = 0.45;

const float XFAC = -0.1;
const float ZFAC = 0.1;

float lightIntensity(vec4 position, vec4 normal) {
#ifdef FANCY
#if defined(NETEASE_SKINNING) && defined(USE_SKINNING)
	MAT4 boneMat = GetBoneMatForNetease(int(BONEID_0));
    vec3 N = normalize( boneMat * NORMAL ).xyz;
#else//NETEASE_SKINNING
	vec3 N = normalize( WORLD * normal ).xyz;
#endif
	N.y *= TILE_LIGHT_COLOR.w; //TILE_LIGHT_COLOR.w contains the direction of the light

	//take care of double sided polygons on materials without culling
#ifdef FLIP_BACKFACES
#if defined(NETEASE_SKINNING) && defined(USE_SKINNING)
	vec3 viewDir = normalize( boneMat * POSITION ).xyz;
#else //NETEASE_SKINNING
	vec3 viewDir = normalize((WORLD * position).xyz);
#endif
	if( dot(N, viewDir) > 0.0 )
		N *= -1.0;
#endif

#ifdef RNGL_LIGHT
	vec3 lightDir = normalize(HIDE_COLOR.xyz);  // light dir uses world coords
	float dLight = max(0.0, dot(N, lightDir));  // diffuse in directional light
	return dLight * (1.0-AMBIENT-0.2) + AMBIENT+0.2;  // origin range [0.65, 1.0]
#else
	float yLight = (1.0+N.y) * 0.5;
	return yLight * (1.0-AMBIENT) + N.x*N.x * XFAC + N.z*N.z * ZFAC + AMBIENT;
#endif // RNGL_LIGHT

#else
	return 1.0;
#endif
}

#ifdef GLINT
vec2 calculateLayerUV(float offset, float rotation) {
	vec2 uv = TEXCOORD_0;
	uv -= 0.5;
	float rsin = sin(rotation);
	float rcos = cos(rotation);
	uv = mat2(rcos, -rsin, rsin, rcos) * uv;
	uv.x += offset;
	uv += 0.5;

	return uv * GLINT_UV_SCALE;
}
#endif


#ifdef USE_UV_FRAME_ANIM
uniform vec4 UV_FRAME_ANIM_PARAM;	//(gridRowInverse, gridColInverse, gridCol, curFrame)

vec2 calculateFrameAnimUV(vec2 uv, float gridRowInverse, float gridColInverse, float gridCol, float curFrame) {
	float curRow = floor(curFrame * gridColInverse + 0.1);
	float curCol = curFrame - curRow * gridCol;	
	return (uv + vec2(curCol, curRow)) * vec2(gridColInverse, gridRowInverse);
}
#endif

float Smooth(float value){
	float Progress = value/1.f*2.f;
	if (Progress < 1.f){
		Progress = pow(value/1.f*2.f, 2.f);
	}
	else{
		Progress = -pow(value/1.f*2.f - 2.f, 2.f);
		Progress += 2.f;
	}
	Progress *= 0.5f;
	return Progress;
}

void main()
{
	POS4 entitySpacePosition;
	POS4 entitySpaceNormal;
	vec4 POSition = POSITION;
	vec3 now_begin_pos = vec3(float(int(EXTRA_VECTOR1.x*1000.f))*0.001f, float(int(EXTRA_VECTOR1.y*1000.f))*0.001f, float(int(EXTRA_VECTOR1.z*1000.f))*0.001f);
	vec3 now_end_pos = vec3(float(int(EXTRA_VECTOR2.x*1000.f))*0.001f, float(int(EXTRA_VECTOR2.y*1000.f))*0.001f, float(int(EXTRA_VECTOR2.z*1000.f))*0.001f);
	vec3 last_begin_pos = vec3(float(int(EXTRA_VECTOR3.x*1000.f))*0.001f, float(int(EXTRA_VECTOR3.y*1000.f))*0.001f, float(int(EXTRA_VECTOR3.z*1000.f))*0.001f);
	vec3 last_end_pos = vec3(float(int(EXTRA_VECTOR4.x*1000.f))*0.001f, float(int(EXTRA_VECTOR4.y*1000.f))*0.001f, float(int(EXTRA_VECTOR4.z*1000.f))*0.001f);
	vec3 EXTRA_VECTOR5_type = vec3(float(int(EXTRA_VECTOR2.w*0.001f))-2.f, float(int(EXTRA_VECTOR3.w*0.001f))-2.f, float(int(EXTRA_VECTOR4.w*0.001f))-2.f);
	vec3 EXTRA_VECTOR5_value = vec3((float(int(EXTRA_VECTOR2.w))*0.001f-float(int(float(int(EXTRA_VECTOR2.w))*0.001f)))*10.f, (float(int(EXTRA_VECTOR3.w))*0.001f-float(int(float(int(EXTRA_VECTOR3.w))*0.001f)))*10.f, (float(int(EXTRA_VECTOR4.w))*0.001f-float(int(float(int(EXTRA_VECTOR4.w))*0.001f)))*10.f);
	vec3 EXTRA_VECTOR6_type = vec3(float(int((EXTRA_VECTOR2.w-float(int(EXTRA_VECTOR2.w)))*10.f))-2.f, float(int((EXTRA_VECTOR3.w-float(int(EXTRA_VECTOR3.w)))*10.f))-2.f, float(int((EXTRA_VECTOR4.w-float(int(EXTRA_VECTOR4.w)))*10.f))-2.f);
	vec3 EXTRA_VECTOR6_value = vec3((EXTRA_VECTOR2.w*10.f-float(int(EXTRA_VECTOR2.w*10.f)))*10.f, (EXTRA_VECTOR3.w*10.f-float(int(EXTRA_VECTOR3.w*10.f)))*10.f, (EXTRA_VECTOR4.w*10.f-float(int(EXTRA_VECTOR4.w*10.f)))*10.f);
	vec3 now_z_end_pos = EXTRA_VECTOR5_type*EXTRA_VECTOR5_value;
	vec3 now_z_begin_pos = EXTRA_VECTOR6_type*EXTRA_VECTOR6_value;
	POSition.z *= 0.01641f;
	POSition.x *= 0.01641f;
	vec3 direct_last = normalize(last_end_pos-last_begin_pos);
	vec3 direct_now = normalize(now_end_pos-now_begin_pos);
	vec3 direct_now_z = normalize(now_z_end_pos-now_z_begin_pos);
	vec3 last_self_pos = (last_begin_pos-now_begin_pos);
	vec3 z_self_pos = (now_z_begin_pos-now_begin_pos);
	POSition.x *= length(now_begin_pos-now_end_pos);
	vec3 POSition1 = mix(direct_now * POSition.x, last_self_pos + direct_last * POSition.x, POSition.z);
	vec3 POSition2 = mix(direct_now * POSition.x, z_self_pos + direct_now_z * POSition.x, POSition.z);
	POSition.xyz = mix(POSition2, POSition1, pow(POSition.z, 2.f));


#ifdef USE_SKINNING
#ifdef NETEASE_SKINNING
		MAT4 boneMat = GetBoneMatForNetease(int(BONEID_0));
		entitySpacePosition = boneMat * POSition;
		entitySpaceNormal = boneMat * NORMAL;
#else
	#if defined(LARGE_VERTEX_SHADER_UNIFORMS)
		entitySpacePosition = BONES[int(BONEID_0)] * POSition;
		entitySpaceNormal = BONES[int(BONEID_0)] * NORMAL;
	#else
		entitySpacePosition = BONE * POSition;
		entitySpaceNormal = BONE * NORMAL;
	#endif
#endif
#else
	entitySpacePosition = POSition * vec4(1, 1, 1, 1);
	entitySpaceNormal = NORMAL * vec4(1, 1, 1, 0);
#endif
	POS4 pos = WORLDVIEWPROJ * entitySpacePosition;
	gl_Position = pos;

#ifdef RNGL_UNLIT
	float L = 1.0;
#else
	float L = lightIntensity(entitySpacePosition, entitySpaceNormal);
#endif

#ifdef USE_OVERLAY
	L += OVERLAY_COLOR.a * 0.35;
#endif

#ifdef TINTED_ALPHA_TEST
	alphaTestMultiplier = OVERLAY_COLOR.a;
#endif

	light = vec4(vec3(L) * TILE_LIGHT_COLOR.xyz, 1.0);

#ifdef COLOR_BASED
	vertColor = COLOR;
#endif
	
#ifdef USE_OVERLAY
	overlayColor = OVERLAY_COLOR;
#endif

#ifndef NO_TEXTURE
	uv = TEXCOORD_0;
#endif

#ifdef USE_UV_ANIM
	uv.xy = UV_ANIM.xy + (uv.xy * UV_ANIM.zw);
#endif

#ifdef USE_UV_FRAME_ANIM
	uv = calculateFrameAnimUV(uv, UV_FRAME_ANIM_PARAM.x, UV_FRAME_ANIM_PARAM.y, UV_FRAME_ANIM_PARAM.z, UV_FRAME_ANIM_PARAM.w);	
#endif

#ifdef GLINT
	glintColor = GLINT_COLOR;
	layer1UV = calculateLayerUV(UV_OFFSET.x, UV_ROTATION.x);
	layer2UV = calculateLayerUV(UV_OFFSET.y, UV_ROTATION.y);
	tileLightColor = TILE_LIGHT_COLOR;
#endif

	//fog
	fogColor.rgb = FOG_COLOR.rgb;
	fogColor.a = clamp(((pos.z / RENDER_DISTANCE) - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);
}