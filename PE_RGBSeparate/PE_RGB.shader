Shader "Unlit/PE_RGB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            UNITY_DECLARE_TEX2D(_MainTex);//声明包含采样器的MainTex
            float4 _MainTex_ST;

            float _Amplitude;
            float _Amount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float splitAmount = _Amount * Random2(_Time.z, 2);
                //float splitAmount = (1.0 + sin(_Time.x * 6.0)) * 0.5;
                float splitAmount = (1.0 + sin(_Time.z * 6.0)) * 0.5;
                splitAmount *= 1.0 + sin(_Time.z * 16.0) * 0.5;
                splitAmount *= 1.0 + sin(_Time.z * 19.0) * 0.5;
                splitAmount *= 1.0 + sin(_Time.z * 27.0) * 0.5;
                splitAmount = pow(splitAmount, _Amplitude);
                splitAmount *= (0.05 * _Amount);

                half3 finalColor;
                finalColor.r = UNITY_SAMPLE_TEX2D(_MainTex, fixed2(i.uv.x + splitAmount , i.uv.y)).r;
                finalColor.g = UNITY_SAMPLE_TEX2D(_MainTex, i.uv).g;
                finalColor.b = UNITY_SAMPLE_TEX2D(_MainTex, fixed2(i.uv.x - splitAmount , i.uv.y)).b;

                finalColor *= (1.0 - splitAmount  * 0.5);

                return half4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
