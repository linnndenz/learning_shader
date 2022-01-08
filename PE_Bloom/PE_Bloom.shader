Shader "Unlit/PE_Bloom"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BlurTex ("Blur Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

         sampler2D _MainTex;
         float4 _MainTex_TexelSize;

         sampler2D _BlurTex;
	     float4 _BlurTex_TexelSize;

         float4 _ColorThreshold;
         float _BloomFactor;

        ENDCG

        //Pass0 超阈值颜色处理
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);

                o.uv = v.uv;
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0){
                    o.uv.y = 1 - o.uv.y;
                }
                #endif

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);

                return saturate(col - _ColorThreshold);
            }
            ENDCG
        }

        //Pass1 简单模糊
        UsePass "Blur/SimpleBlur"
        //Pass2 v模糊
        UsePass "Blur/VerticalBlur"
        //Pass3 h模糊
        UsePass "Blur/HorizontalBlur"

        //Pass4 Bloom
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

             struct v2f
             {
                 float2 uv : TEXCOORD0;
                 float4 vertex : SV_POSITION;
             };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.uv;
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0){
                    o.uv.y = 1 - o.uv.y;
                }
                #endif
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
		        //输出= 原始图像，叠加模糊图像
		        float4 col = tex2D(_MainTex, i.uv) + tex2D(_BlurTex, i.uv)*_BloomFactor;

                return col;
            }
            ENDCG
        }

    }
}
