Shader "Custom/WaterSurface"
{ 
	Properties
	{
	_MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
	_BumpMap("Normal Map", 2D) = "bump" {}
	_FoamMap("Distortion Map", 2D) = "black" {}

	[HiddenInInspector] _ReflectionMap("Reflection RT", 2D) = "white" {}
	[HiddenInInspector] _UV("UV", Range(-1,1)) = 0
	[HiddenInInspector] _pp("pp", Range(-1,1)) = 0
}
SubShader{
	Tags{ "RenderType" = "Opaque" }
	CGPROGRAM
#pragma surface surf Lambert
#pragma target 3.5

float _UV;
float _pp;
sampler2D _BumpMap;
sampler2D _MainTex;
sampler2D _ReflectionMap;
sampler2D _FoamMap;
fixed4 _Color;


struct Input
{
	float3 viewDir;
	float2 uv_BumpMap;
	float2 uv_MainTex : TEXCOORD0;
};

float2 DistUV(float2 uv, float2 foam, float pp) 
{
	float distortion = pp;
	float2 uvR;
	uvR.x = uv.x + foam * distortion;
	uvR.y = uv.y +foam * distortion*0.1;
	return uvR;
}
void surf(Input IN, inout SurfaceOutput o)
{

	//dist reflection
	half2 texcoord = UnpackNormal(tex2D(_FoamMap, IN.uv_MainTex));
	float2 uv = DistUV(IN.uv_MainTex, 0.15*texcoord, _pp);
	half3 color = tex2D(_MainTex, uv).rgb *_Color;
	texcoord = IN.uv_MainTex; //discard old content, re -use variable
	texcoord = half2(1 - uv.x, uv.y);
	half3 refl = tex2D(_ReflectionMap, texcoord).rgb;

	//make 2D-3D perspective
	half2 perspectiveCorrection = half2(2.0f * (0.5 - IN.uv_MainTex.x) * IN.uv_MainTex.y, 0.0f);
	texcoord = uv;//perspectiveCorrection +uv;

	texcoord.x += _UV;

	half3 tex2 = UnpackNormal(tex2D(_FoamMap, texcoord));// *0.25 + perspectiveCorrection));
	o.Normal = lerp(tex2,UnpackNormal(tex2D(_BumpMap, texcoord)),0.75); //I thought this could do a nice view
	//o.Normal = UnpackNormal(tex2D(_BumpMap, texcoord));
	color = lerp(color,refl,0.5 );

	o.Albedo = color.rgb;
}
ENDCG
}
Fallback "Diffuse"
}
