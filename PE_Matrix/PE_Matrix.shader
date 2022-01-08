Shader "Unlit/PE_Matrix"
{
   Properties
	{
		_MainTex("Main Texture",2D)="white"{}

		[HDR]_Color ("Color", Color) = (1,1,1,1)
		_FlowingTex ("Flowing Tex", 2D) = "white" {}
		_TextTex ("Number Tex", 2D) = "white" {}
		_CellSize ("Cell Size (xyz)", Vector) = (0.03, 0.04, 0.03, 0)
		_TexSizes ("Flowing Texel Size, Number Count", Vector) = (256, 10, 0,0)
		_Speed ("Flowing Speed, Number Changing Speed", Vector) = (1,5,0,0)
	}

	Subshader
	{
		//Tags{"RenderType"="Transparent"}
		Tags
			{
				"RenderType"="Transparent"
				"Queue"="Transparent"
				"IgnoreProjector"="True"
			}
		Pass
		{
			//Fog { Mode Off }
			//Lighting Off
			//Blend One One
			//Cull Off
			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			//目录别乱改，强随机类型，改成随机取数可不用噪点图
			#include "../Random.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _RandomTex;
			sampler2D _FlowingTex;
			sampler2D _TextTex;
			float4 _CellSize;
			float4 _TexSizes;
			float4 _Speed;
			
			#define _FlowingTexelSize (1/_TexSizes.x)
			#define _NumberCount (_TexSizes.y)
			#define T (_Time.y)
			#define EPSILON (0.00876)

			struct appdata_v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
				float3 objPos : TEXCOORD1;
			};

			v2f vert (appdata_v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos (v.vertex);
				o.objPos = v.vertex.xyz;
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 cellc = i.objPos.xyz / _CellSize + EPSILON;//单个数字大小
				//流速随机
				float speed = Random((int)(cellc.x)) * 3 + 1;
				cellc.y += T*speed*_Speed.x;//向下流动
				float intens = tex2D(_FlowingTex, cellc.xy * _FlowingTexelSize).r;
				
				//数字随机
				float2 nc = cellc;
				nc.x += round(T*_Speed.y*speed);
				float number = round(Random(float2((int)nc.y,(int)nc.x)/1000) * _NumberCount) / _NumberCount;
				
				//数字采样
				float2 number_tex_base = float2(number, 0);
				float2 number_tex = number_tex_base + float2(frac(cellc.x/_NumberCount), frac(cellc.y));
				fixed4 ncolor = tex2Dlod(_TextTex, float4(number_tex, 0, 0)).rgba;
				
				//intens改成控制透明度
				fixed4 col = ncolor * fixed4(1,1,1,pow(intens,2)) * _Color;
				return col;
			}
			ENDCG
		}

		//1，混合输出
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			sampler2D _MainTex;
			sampler2D _MatrixTex;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos (v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 main = tex2D(_MainTex,i.uv);
				float4 matri = tex2D(_MatrixTex,i.uv);

				float4 col=matri;
				if(col.a<0.01f){
					col=main;
				}else{
					col = max(main,col);
				}
				return col;
			}
			ENDCG
		}
    }
}
