Shader "Unlit/Emission_Breathe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [HDR]_Color("Color",Color)=(1,1,1,1)
        _MaxBloom("Max Bloom",Range(0,10))=5
        _BreatheSpeed("Breathe Speed",Range(0,200))=2
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
            // make fog work
            #pragma multi_compile_fog

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _MaxBloom;
            float _BreatheSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);

                float intensity = _MaxBloom * (1.5f + sin(_Time * _BreatheSpeed)) * 0.5;
                return col*_Color* pow(2,intensity);
            }
            ENDCG
        }
            UsePass "ToolPass/ShadowCaster"
    }
}
