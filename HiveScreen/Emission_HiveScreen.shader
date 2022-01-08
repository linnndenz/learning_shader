Shader "Unlit/Emission_HiveScreen"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PixelSize ("Pixel Size", Range(1,20)) = 4

		_CullColor("Cull Color",Color)=(1,1,1,1)
        [HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)
        _BackColor("Back Color",Color)=(1,1,1,1)
		_Gap("Gap",Range(0,20))=2
		_Threshold("Threshold",Range(0,1))=0.5
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

		Pass
		{
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			//上色
            fixed4 _CullColor;
            float4 _EmissionColor;
            fixed4 _BackColor;
			fixed _Threshold;

			//间距
			float _PixelSize;
			float _Gap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = 1-o.uv;
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				const float TR = 0.866025;//TR=√3
				float2 xyUV = (i.uv*_MainTex_TexelSize.zw);
				uint wx = int (xyUV.x/1.5f/_PixelSize);
				uint wy = int (xyUV.y/TR/_PixelSize);
				 
				float2 v1,v2;
				float2 wxy =float2(wx,wy);
				if(wx/2*2==wx){//过半
					if(wy/2*2==wy){
						v1 = wxy;
						v2 = wxy+1;
					}
					else{
						v1 = wxy+float2(1,0);
						v2 = wxy+float2(0,1);
					}	
				}
				else{
					if(wy/2*2 == wy){
						v1 = wxy+float2(1,0);
						v2 = wxy+float2(0,1);
					}
					else{
						v1 = wxy;
						v2 = wxy+1;
					}
				}
				v1 *= float2(_PixelSize*1.5f,_PixelSize*TR);
				v2 *= float2(_PixelSize*1.5f,_PixelSize*TR);
				
				//*************
				float s1 = length(v1.xy-xyUV.xy);
				float s2 = length(v2.xy-xyUV.xy);
				float4 col = tex2D(_MainTex,v2*_MainTex_TexelSize.xy);
				
				//控制间隙
				if(abs(s1 - s2)<_Gap / 2 
					|| (s1<s2 && TR*_PixelSize - _Gap/4*TR < abs(xyUV.y-v1.y))
					|| (s1>s2 && TR*_PixelSize - _Gap/4*TR < abs(xyUV.y-v2.y))){
						col = _CullColor;
				}else if(s1 < s2)  {
					col = tex2D(_MainTex,v1*_MainTex_TexelSize.xy);
				}

				col = lerp(_BackColor,_EmissionColor,step(_Threshold,distance(col , _CullColor)));

				//if(!distance(col , _CullColor)<1){
				//	col = _EmissionColor;
				//}else{
				//	col = _BackColor;
				//}

				//if(distance(col , _CullColor)<_Threshold){
				//	col = _BackColor;
				//}else{
				//	col = _EmissionColor;
				//}
				return col;

			}
			ENDCG
		}
	}
}