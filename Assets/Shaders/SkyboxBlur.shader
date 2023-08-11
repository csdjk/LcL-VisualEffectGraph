// ================================= LOD Blur 天空盒 =================================
Shader "LcL/Skybox/SkyboxBlur"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        _Blur ("Blur", Range(0, 1)) = 0
        [NoScaleOffset] _Tex ("Cubemap(HDR)", Cube) = "grey" { }
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
        Cull Off ZWrite Off

        Pass
        {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore metal vulkan d3d11

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
            
            TEXTURECUBE(_Tex);
            SAMPLER(sampler_Tex);
            CBUFFER_START(UnityPerMaterial)
                half4 _Tex_HDR;
                half4 _Tint;
                half _Exposure;
                float _Rotation;
                float _Blur;
            CBUFFER_END

            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            struct appdata_t
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata_t input)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated = RotateAroundYInDegrees(input.vertex.xyz, _Rotation);
                VertexPositionInputs vertexInput = GetVertexPositionInputs(rotated);

                o.vertex = vertexInput.positionCS;
                o.texcoord = input.vertex.xyz;
                o.positionWS = vertexInput.positionWS;
                return o;
            }

            half4 frag(v2f input) : SV_Target
            {
                float lod = _Blur * 6.0f;
                half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(_Tex, sampler_Tex, input.texcoord, lod));
                #if defined(UNITY_USE_NATIVE_HDR)
                    half3 color = encodedIrradiance.rgb;
                #else
                    half3 color = DecodeHDREnvironment(encodedIrradiance, _Tex_HDR);
                #endif
                
                color = color * _Tint.rgb * 2;
                color *= _Exposure;

                return half4(color, 1);
            }
            ENDHLSL
        }
    }


    Fallback Off
}
