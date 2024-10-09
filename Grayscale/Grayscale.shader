Shader "Hidden/Shader/GrayscalePostProcess"
{
    Properties 
    {
		// This property is necessary to make the CommandBuffer.Blit bind the source texture to _MainTex
		_MainTex("", 2DArray) = "" {}
    }

    HLSLINCLUDE

	#pragma target 4.5
	#pragma only_renderers d3d11 vulkan metal
	
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

    struct Attributes
	{
		uint vertexID : SV_VertexID;
	};
	struct Varyings
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	Varyings Vert(Attributes v)
	{
		Varyings o;
		o.pos = GetFullScreenTriangleVertexPosition(v.vertexID);
		o.uv = GetFullScreenTriangleTexCoord(v.vertexID);
		return o;
	}

	TEXTURE2D_X(_MainTex);

	// Luminosity Rec. 601 formula
	float4 frag_601(Varyings i) : SV_Target
    {
        float4 tex = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, i.uv);
        float lum = tex.r * 0.299 + tex.g * 0.587 + tex.b * 0.114;
        return float4(lum, lum, lum, tex.a);
    }

	// Luminosity Rec. 709 formula
	float4 frag_709(Varyings i) : SV_Target
    {
        float4 tex = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, i.uv);
        float lum = tex.r * 0.2126 + tex.g * 0.7152 + tex.b * 0.0722;
        return float4(lum, lum, lum, tex.a);
    }

	// Average formula
	float4 frag_average(Varyings i) : SV_Target
    {
        float4 tex = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, i.uv);
        float lum = (tex.r + tex.g + tex.b) / 3.0;
        return float4(lum, lum, lum, tex.a);
    }

	// Lightness formula
	float4 frag_lightness(Varyings i) : SV_Target
    {
        float4 tex = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, i.uv);
        float lum = (max(tex.r, max(tex.g, tex.b)) + min(tex.r, min(tex.g, tex.b))) / 2.0;
        return float4(lum, lum, lum, tex.a);
    }

	ENDHLSL

    SubShader 
    {
		ZWrite Off ZTest Always Blend Off Cull Off

		// Luminosity Rec. 601 formula
        Pass
        {
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag_601
            ENDHLSL
        }

		// Luminosity Rec. 709 formula
		Pass
        {
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag_709
            ENDHLSL
        }

		// Average formula
        Pass
        {
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag_average
            ENDHLSL
        }

		// Lightness formula
        Pass
        {
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag_lightness
            ENDHLSL
        }
    }
    Fallback Off
} 