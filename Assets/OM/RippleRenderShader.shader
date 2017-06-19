Shader "Ripple/RippleRenderShader"
{
	Properties
	{
		_MainTex ("_MainTex", 2D) = "white" {}
		_RippleTex ("_RippleTex", 2D) = "white" {}
		_Perturbance ("perturbance", Float) = 0.03
	}
	SubShader
	{
		Tags { "Queue"="Geometry+1000" "RenderType"="Opaque" }
		LOD 100

		GrabPass{"_Background"}

		Pass
		{
			Blend One Zero
			ZTest Always 
			//Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

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
			sampler2D _RippleTex;
			sampler2D _Background;
			float _Perturbance;
			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 ripple = tex2D(_RippleTex, i.uv);
				float2 offset = -ripple.ba;
				float specular = pow(max(0,dot(offset, normalize(float2(-0.6, 1)))), 4);
				float4 color = tex2D(_Background, i.uv + offset * _Perturbance) + specular;
				//return float4(ripple.r,0,0,1);
				return float4(color.rgb,1);
			}
			ENDCG
		}
	}
}
