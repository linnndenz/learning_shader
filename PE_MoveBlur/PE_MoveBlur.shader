Shader "Unlit/PE_MoveBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Iteration("Iteration",Int) = 16
    }
    SubShader
    {
        ZTest Always

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

            int _Iteration;
            float _Intensity;
            float2 _Offset;
            float _BlurWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv-=_Offset;
                _Intensity*=0.085;
                float scale = 1;

                fixed4 col = fixed4(0,0,0,0);
                for(int j = 1;j < _Iteration;j++){
                    col += tex2D(_MainTex,i.uv * scale +_Offset);
                    scale = 1.0f + j * _Intensity;
                }

                return col/_Iteration;
            }
            ENDCG
        }
    }
}
