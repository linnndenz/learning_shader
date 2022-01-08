Shader "Unlit/wwdd"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

         _High("High border",Range(0,2))=1
        _Low("Low border",Range(-1,1))=0
        _Speed("Speed",Range(0,200))=2
        _Amplitude("Amplitude",Range(0,2))=1

         _OriColor("Origin Color",Color)=(1,1,1,1)
        [HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)
        _BlinkSpeed("Blink Speed",Range(0,500))=200
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

            fixed _High;
            fixed _Low;
            float _Speed;
            float _Amplitude;

            fixed4 _OriColor;
            float4 _EmissionColor;
            float _BlinkSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float center=(_High+_Low)/2;
                float halfHeight=(_High-_Low)/2;
                //∫·œÚ
                float refl=saturate(halfHeight-abs(i.uv.y-center))/halfHeight;
                i.uv.x+=(sin(_Time*_Speed)*_Amplitude)*smoothstep(0,1,refl);

                fixed4 col = tex2D(_MainTex, i.uv);
                 if(distance(col , _OriColor)<0.99){
                    col = _EmissionColor*pow(2,sin(_Time.x*_BlinkSpeed)+1);
                }
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
