Shader "Unlit/PE_SceneScan"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		//ZTest Always ZWrite Off Cull Off
		Tags { "RenderType" = "Background" "Queue" = "Overlay+1000" "IgnoreProjector" = "True" }
		LOD 100
 
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
 
			#include "UnityCG.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				//float2 uv_depth : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};
 
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _CameraDepthTexture;

			float _ScanDistance;
			float _ScanEnd;
			float _ScanWidth;

			fixed4 _LineColor;
			fixed4 _ScanColor;

			float _LineNum;
			float _Gap;
 
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.uv_depth = v.uv;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float linear01Depth = Linear01Depth(depth);

				bool bLine = false;

				if(linear01Depth < 1 && linear01Depth > _ScanEnd){
					//扫描线
					for(int n = 0; n < _LineNum; n++){
						if(linear01Depth < _ScanDistance*n*_Gap && linear01Depth > _ScanDistance*n*_Gap - _ScanWidth){
							col += _LineColor * (_LineNum - n)/_LineNum;
							bLine = true;
						}
					}
					//扫描过的区域（除扫描线）
					if(!bLine && linear01Depth > 0 && linear01Depth<_ScanDistance*_Gap*_LineNum){
						col *= _ScanColor;
					}
				}

				//if (linear01Depth < _ScanDistance && linear01Depth > _ScanDistance - _ScanWidth && linear01Depth < 1)
				//{
				//	//处于扫描区域渐变效果 (近到远逐渐加深颜色) 即需要一个 0 渐变到 1 的float
				//	float diff = 1 - (_ScanDistance - linear01Depth) / _ScanWidth;
				//	return col + _ScanColor * diff;
				//}
				return col;
			}
			ENDCG
		}
	}
}