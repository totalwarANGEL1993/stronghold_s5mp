
// Includes...

#include "Skinning.fx"


// Effect properties...

const string EffectProperty_ShadowEffect = "ShadowSkinnedObject";
const bool   EffectProperty_IsUnit       = true;


// Parameters set by the application...

shared float4x4 g_MatView : View;
shared float4x4 g_MatProjection : Projection;

float4x4 g_MatWorld : World;
float4x4 g_MatWorldView : WorldView;
float4x4 g_MatWorldViewProjection : WorldViewProjection;

float4 g_MaterialDiffuseAmbient : MaterialDiffuseAmbient;

shared float4 g_LightAmbient : LIGHT_AMBIENT;
shared float4 g_LightDiffuse0 : LIGHT_DIRECT_DIFFUSE_0;
shared float4 g_LightDirection0 : LIGHT_DIRECT_DIR_0;

texture g_TexDiffuse  : Diffuse0 = NULL;
texture g_TexSpecular : Diffuse1 = NULL;


// Vertex declarations...

struct SVertexInput
{
	float4 m_Position     : POSITION;
	float3 m_Normal       : NORMAL;
	float4 m_BlendIndices : BLENDINDICES;
	float2 m_BlendWeights : BLENDWEIGHT;
	float2 m_TexCoord0    : TEXCOORD0;
};

struct SVertexOutput
{
    float4 m_Position  : POSITION;
    float4 m_Color0    : COLOR0;
	float2 m_TexCoord0 : TEXCOORD0;
};


// VertexShaderSkinnedUnit

SVertexOutput VertexShaderSkinnedUnit(SVertexInput _In)
{
	SVertexOutput Out;
	
	int4 Indices = D3DCOLORtoUBYTE4(_In.m_BlendIndices);
	float2 Weights = _In.m_BlendWeights;
	
	float3 Position = { 0, 0, 0 };
	float3 Normal = { 0, 0, 0 };
	
	for (int i = 0; i < 2; i++)
	{
		int Index = Indices[i];

		float3x4 BoneTranformation = float3x4(g_Bones[Index], g_Bones[Index+1], g_Bones[Index+2]);

		Position += Weights[i] * mul(BoneTranformation, _In.m_Position);
		Normal += Weights[i] * mul((float3x3) BoneTranformation, _In.m_Normal);
	}
	
    float3 WorldNormal = normalize(mul(Normal, (float3x3) g_MatWorld));
    
	Out.m_Position = mul(float4(Position, 1), g_MatWorldViewProjection);
    Out.m_Color0 = g_MaterialDiffuseAmbient * (g_LightAmbient + g_LightDiffuse0 * max(0, dot(WorldNormal, -g_LightDirection0)));
    Out.m_TexCoord0 = _In.m_TexCoord0;
    
	return Out;
}


// Sampler...

sampler DiffuseSampler = sampler_state 
{
    Texture = <g_TexDiffuse>;
	AddressU = WRAP;
	AddressV = WRAP;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};


// PixelShaderAlphaBlending...

float4 PixelShaderAlphaBlending(SVertexOutput _In) : COLOR
{
    float4 Diffuse = tex2D(DiffuseSampler, _In.m_TexCoord0);
    float4 rgba_mask = { 0, 0, 0, 0 };
    return float4((float3) _In.m_Color0 * lerp((float3) rgba_mask, (float3) Diffuse, Diffuse.a), Diffuse.a);
}


// Techniques...

technique Default
{
   pass Default
   {
      VertexShader = compile vs_1_1 VertexShaderSkinnedUnit();
      PixelShader = compile ps_1_1 PixelShaderAlphaBlending();
   }
}

