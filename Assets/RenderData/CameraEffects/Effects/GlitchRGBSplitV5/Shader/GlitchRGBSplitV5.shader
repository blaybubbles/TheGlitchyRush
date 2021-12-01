

Shader "Hidden/X-PostProcessing/Glitch/RGBSplitV5"
{
	Properties
	{
		[HideInInspector] _MainTex("Base (RGB)", 2D) = "white" {}
		_NoiseTex("Base (RGB)", 2D) = "white" {}
		_Delta("Line Thickness", Range(0.0005, 0.0025)) = 0.001
		_Amplitude("_Amplitude", Range(0.0, 5.0)) = 3.0
		_Speed("_Speed", Range(0.0, 1.0)) = 0.5
		[Toggle(RGB_SPLIT_ON)]_Raw("RGBSplitV5_ON", Float) = 0
		[Toggle(POSTERIZE)]_Poseterize("Posterize", Float) = 0
		_PosterizationCount("Count", int) = 8
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			Pass
			{
				HLSLPROGRAM
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
				#define TEXTURE2D_SAMPLER2D(textureName, samplerName) Texture2D textureName; SamplerState samplerName
				#pragma shader_feature RGB_SPLIT_ON
				#pragma shader_feature POSTERIZE

				TEXTURE2D(_CameraDepthTexture);
				SAMPLER(sampler_CameraDepthTexture);

	#ifndef RAW_OUTLINE
				TEXTURE2D(_MainTex);
				SAMPLER(sampler_MainTex);
	#endif
				float _Delta;
				int _PosterizationCount;
				TEXTURE2D_SAMPLER2D(_NoiseTex, sampler_NoiseTex);

				float _Amplitude;
				float _Speed;

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
				inline float4 Pow4(float4 v, float p)
				{
					return float4(pow(v.x, p), pow(v.y, p), pow(v.z, p), v.w);
				}

				inline float4 Noise(float2 p)
				{
					return SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, p);
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
					 #ifdef RGB_SPLIT_ON
					float4 splitAmount = Pow4(Noise(float2(_Speed * _Time.y, 2.0 * _Speed * _Time.y / 25.0)), 8.0) * float4(_Amplitude, _Amplitude, _Amplitude, 1.0);

					splitAmount *= 2.0 * splitAmount.w - 1.0;

					half colorR = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (input.uv.xy + float2(splitAmount.x, -splitAmount.y))).r;
					half colorG = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (input.uv.xy + float2(splitAmount.y, -splitAmount.z))).g;
					half colorB = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (input.uv.xy + float2(splitAmount.z, -splitAmount.x))).b;

					half3 finalColor = half3(colorR, colorG, colorB);
#else
					half3 finalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
					#endif
					return half4(finalColor,1);

					/* UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

					 float s = pow(1 - saturate(sobel(input.uv)), 50);
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
			FallBack "Diffuse"
				/*HLSLINCLUDE

				#include "../../../Shaders/XPostProcessing.hlsl"


				TEXTURE2D_SAMPLER2D(_NoiseTex, sampler_NoiseTex);

				uniform half2 _Params;
				#define _Amplitude _Params.x
				#define _Speed _Params.y


				inline float4 Pow4(float4 v, float p)
				{
					return float4(pow(v.x, p), pow(v.y, p), pow(v.z, p), v.w);
				}

				inline float4 Noise(float2 p)
				{
					return SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, p);
				}

				half4 Frag(VaryingsDefault i): SV_Target
				{
					float4 splitAmount = Pow4(Noise(float2(_Speed * _Time.y, 2.0 * _Speed * _Time.y / 25.0)), 8.0) * float4(_Amplitude, _Amplitude, _Amplitude, 1.0);

					splitAmount *= 2.0 * splitAmount.w - 1.0;

					half colorR = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.texcoord.xy + float2(splitAmount.x, -splitAmount.y))).r;
					half colorG = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.texcoord.xy + float2(splitAmount.y, -splitAmount.z))).g;
					half colorB = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.texcoord.xy + float2(splitAmount.z, -splitAmount.x))).b;

					half3 finalColor = half3(colorR, colorG, colorB);
					return half4(finalColor,1);

				}

				ENDHLSL*/


				/*SubShader
				{
					Cull Off ZWrite Off ZTest Always

					Pass
					{
						HLSLPROGRAM

						#pragma vertex VertDefault
						#pragma fragment Frag

						ENDHLSL

					}
				}*/
}


