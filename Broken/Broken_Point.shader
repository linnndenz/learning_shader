Shader "Unlit/Broken_Point"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //иак╦
        [HDR]_BackColor("Back Color",Color)=(0,0,0,1)
        _RandomFactor("Radom Factor",Range(0,1))=0.5
        _Pixel("Pixel",Range(1,1000))=500
        _BlinkSpeed("Blink Speed",Range(1,500))=100
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
            #include "Random.cginc"

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
            fixed4 _Color;
            
            //иак╦
            fixed4 _BackColor;
            fixed _RandomFactor;
            float _Pixel;
            float _BlinkSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = (int2)(i.uv * _Pixel) / _Pixel;
                float random = Random2(uv*(int)(_Time*_BlinkSpeed)/_BlinkSpeed);
                fixed4 col = lerp(tex2D(_MainTex, i.uv) *_Color,_BackColor,step(_RandomFactor,random));
                return col;
            }
            ENDCG
        }
    }
}
