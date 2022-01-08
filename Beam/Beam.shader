Shader "Unlit/Beam"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_SrcColor("Src Color",Color)=(1,1,1,1)
        [HDR]_EndColor("End Color",Color)=(1,1,1,1)

        _ColorLerp("Color Lerp",Range(0,1.5)) = 1
        _AlphaLerp("Alpha Lerp",Range(0,1.5)) = 1
        _BeamLength("Beam Length",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent-5" }
        LOD 100

        Pass
        {
        Blend SrcAlpha OneMinusSrcAlpha
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

            float4 _SrcColor;
            float4 _EndColor;
            float _ColorLerp;
            float _AlphaLerp;
            float _BeamLength;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                smoothstep(0,_BeamLength,i.uv.y);
                col = lerp(_EndColor, _SrcColor, (_BeamLength - i.uv.y) * _ColorLerp);
                col.a = lerp(0, 1, (_BeamLength - i.uv.y) * _AlphaLerp);
                if(i.uv.y > _BeamLength) col.a = 0;
                return col;
            }
            ENDCG
        }

        UsePass "ToolPass/ShadowCaster"
    }
}
