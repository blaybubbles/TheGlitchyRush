
//----------------------------------------------------------------------------------------------------------
// X-PostProcessing Library
// https://github.com/QianMo/X-PostProcessing-Library
// Copyright (C) 2020 QianMo. All rights reserved.
// Licensed under the MIT License 
// You may not use this file except in compliance with the License.You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
//----------------------------------------------------------------------------------------------------------

Shader "Hidden/X-PostProcessing/ColorAdjustment/BleachBypass"
{
	Properties
	{
		[HideInInspector] _MainTex("Base (RGB)", 2D) = "white" {}
		_Delta("Line Thickness", Range(0.0005, 0.0025)) = 0.001
		_Indensity("_Indensity", Range(0.0, 1.0)) = 0.5
		[Toggle(RAW_OUTLINE)]_Raw("Outline Only", Float) = 0
		[Toggle(POSTERIZE)]_Poseterize("Posterize", Float) = 0
		_PosterizationCount("Count", int) = 8
	}
		//HLSLINCLUDE
		//
		//
	 //   #include "../../../Shaders/StdLib.hlsl"
	 //   #include "../../../Shaders/XPostProcessing.hlsl"
		//uniform half _Indensity;
		//
		//half luminance(half3 color)
		//{
		//	return dot(color, half3(0.222, 0.707, 0.071));
		//}
		//
		////reference : https://developer.download.nvidia.com/shaderlibrary/webpages/shader_library.html
		//half4 Frag(VaryingsDefault i): SV_Target
		//{	
		//	half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		//	half lum = luminance(color.rgb);
		//	half3 blend = half3(lum, lum, lum);
		//	half L = min(1.0, max(0.0, 10.0 * (lum - 0.45)));
		//	half3 result1 = 2.0 * color.rgb * blend;
		//	half3 result2 = 1.0 - 2.0 * (1.0 - blend) * (1.0 - color.rgb);
		//	half3 newColor = lerp(result1, result2, L);
		//	
		//	return lerp(color, half4(newColor, color.a), _Indensity);
		//}
		//
		//ENDHLSL

		SubShader
		{
			//Cull Off ZWrite Off ZTest Always
			Tags { "RenderType" = "Opaque" }
			LOD 200

			Pass
			{
				/*HLSLPROGRAM

				#pragma vertex VertDefault
				#pragma fragment Frag

				ENDHLSL*/

				 HLSLPROGRAM
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

				 //#include "../../../Shaders/StdLib.hlsl"
				 //#include "../../../Shaders/XPostProcessing.hlsl"
				 #pragma shader_feature RAW_OUTLINE
				 #pragma shader_feature POSTERIZE

				 TEXTURE2D(_CameraDepthTexture);
				 SAMPLER(sampler_CameraDepthTexture);

	 #ifndef RAW_OUTLINE
				 TEXTURE2D(_MainTex);
				 SAMPLER(sampler_MainTex);
	 #endif
				 float _Delta;
				 float _Indensity;
				 int _PosterizationCount;

				 struct Attributes
				 {
					 float4 positionOS       : POSITION;
					 float2 uv               : TEXCOORD0;
				 };

				 struct Varyings
				 {
					 float2 uv        : TEXCOORD0;
					 float4 vertex : SV_POSITION;
					 UNITY_VERTEX_OUTPUT_STEREO
				 };

				 float SampleDepth(float2 uv)
				 {
	 #if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
					 return SAMPLE_TEXTURE2D_ARRAY(_CameraDepthTexture, sampler_CameraDepthTexture, uv, unity_StereoEyeIndex).r;
	 #else
					 return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv);
	 #endif
				 }

				 half luminance(half3 color)
	 {
		 return dot(color, half3(0.222, 0.707, 0.071));
	 }

				 float sobel(float2 uv)
				 {
					 float2 delta = float2(_Delta, _Delta);

					 float hr = 0;
					 float vt = 0;

					 hr += SampleDepth(uv + float2(-1.0, -1.0) * delta) * 1.0;
					 hr += SampleDepth(uv + float2(1.0, -1.0) * delta) * -1.0;
					 hr += SampleDepth(uv + float2(-1.0,  0.0) * delta) * 2.0;
					 hr += SampleDepth(uv + float2(1.0,  0.0) * delta) * -2.0;
					 hr += SampleDepth(uv + float2(-1.0,  1.0) * delta) * 1.0;
					 hr += SampleDepth(uv + float2(1.0,  1.0) * delta) * -1.0;

					 vt += SampleDepth(uv + float2(-1.0, -1.0) * delta) * 1.0;
					 vt += SampleDepth(uv + float2(0.0, -1.0) * delta) * 2.0;
					 vt += SampleDepth(uv + float2(1.0, -1.0) * delta) * 1.0;
					 vt += SampleDepth(uv + float2(-1.0,  1.0) * delta) * -1.0;
					 vt += SampleDepth(uv + float2(0.0,  1.0) * delta) * -2.0;
					 vt += SampleDepth(uv + float2(1.0,  1.0) * delta) * -1.0;

					 return sqrt(hr * hr + vt * vt);
				 }

				 Varyings vert(Attributes input)
				 {
					 Varyings output = (Varyings)0;
					 UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

					 VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
					 output.vertex = vertexInput.positionCS;
					 output.uv = input.uv;

					 return output;
				 }

				 half4 frag(Varyings input) : SV_Target
				 {
					 UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);


					 half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
					 half lum = luminance(color.rgb);
					 half3 blend = half3(lum, lum, lum);
					 half L = min(1.0, max(0.0, 10.0 * (lum - 0.45)));
					 half3 result1 = 2.0 * color.rgb * blend;
					 half3 result2 = 1.0 - 2.0 * (1.0 - blend) * (1.0 - color.rgb);
					 half3 newColor = lerp(result1, result2, L);

					 return lerp(color, half4(newColor, color.a), _Indensity);

		 /*float s = pow(1 - saturate(sobel(input.uv)), 50);
#ifdef RAW_OUTLINE
				return half4(s.xxx, 1);
#else
				half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
#ifdef POSTERIZE
				col = pow(col, 0.4545);
				float3 c = RgbToHsv(col);
				c.z = round(c.z * _PosterizationCount) / _PosterizationCount;
				col = float4(HsvToRgb(c), col.a);
				col = pow(col, 2.2);
#endif
				return col * s;
#endif*/
			}

			#pragma vertex vert
			#pragma fragment frag

			ENDHLSL

		}
		}
}


