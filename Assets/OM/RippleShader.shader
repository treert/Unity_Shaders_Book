Shader "Ripple/RippleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DropPosX ("Drop Pos X", Float) = 0
		_DropPosY ("Drop Pos Y", Float) = 0
		_DropRadius ("Drop Radius", Float) = 10
		_DropStrength ("Drop Strength", Float) = 0.6
	}
	SubShader
	{
		Tags { "Queue"="Geometry+1" "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

			
		sampler2D _MainTex;
		//float4 _MainTex_ST;
		float4 _MainTex_TexelSize;
		float _DropPosX;
		float _DropPosY;
		float _DropRadius;
		float _DropStrength;
			
			
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex.xy = (v.vertex.xy * 2 - 1);
			o.vertex.z = 0;
			o.vertex.w = 1;
			o.uv = v.uv;
			#if UNITY_UV_STARTS_AT_TOP
			o.uv.y = 1 - o.uv.y;
			#endif
			return o;
		}
			
		float4 frag_drop (v2f i) : SV_Target
		{
			float4 info = tex2D(_MainTex, i.uv);

			float PI = 3.141592653589793;// do not support const float PI = 3.141592653589793; 
			float drop = max(0,1 - length(float2(_DropPosX, _DropPosY) - i.uv * _MainTex_TexelSize.zw)/_DropRadius);
			drop = 0.5 - cos(drop * PI) * 0.5;

			info.r += drop * _DropStrength;
			return info;
		}

		float4 frag_high_change (v2f i) : SV_Target
		{
			float4 info = tex2D(_MainTex, i.uv);
				
			float2 dx = float2(_MainTex_TexelSize.x,0);
			float2 dy = float2(0, _MainTex_TexelSize.y);

			float avg = (
				tex2D(_MainTex, i.uv -dx).r +
				tex2D(_MainTex, i.uv +dx).r +
				tex2D(_MainTex, i.uv -dy).r +
				tex2D(_MainTex, i.uv +dy).r
			)*0.25;

			info.g += (avg - info.r) * 2;
			info.g *= 0.995;
			info.r += info.g;
			info.r = max(0,info.r - 0.0001);

			return info;
		}

		float4 frag_uv(v2f i) : SV_Target
		{
			float4 info = tex2D(_MainTex, i.uv);


			float3 dx = float3(_MainTex_TexelSize.x, tex2D(_MainTex,float2(i.uv.x + _MainTex_TexelSize.x, i.uv.y)).r - info.r, 0);
			float3 dy = float3(0, tex2D(_MainTex,float2(i.uv.x, i.uv.y  + _MainTex_TexelSize.y)).r  - info.r, _MainTex_TexelSize.y);
			info.ba = normalize(cross(dy,dx)).xz;

			return info;
		}
		ENDCG

		Blend One Zero
		ZTest Always Cull Off ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_drop

			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_high_change

			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_uv

			ENDCG
		}
	}
}
