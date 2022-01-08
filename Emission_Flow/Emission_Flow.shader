Shader "Unlit/Emission_Flow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color1("Color1",Color)=(1,1,1,1)
        _Color2("Color2",Color)=(1,1,1,1)
        _Color3("Color3",Color)=(1,1,1,1)
        _Color4("Color4",Color)=(1,1,1,1)
        _Color5("Color5",Color)=(1,1,1,1)

        _Bloom("Bloon Intensity",Range(0,10))=5
        _FlowSpeed("Flow Speed",Range(0,3))=1
        _Offset("Flow Offset",Range(0,10))=0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent-5" }
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

            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float4 _Color4;
            float4 _Color5;

            float _Bloom;
            float _FlowSpeed;
            float _Offset;

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
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);

                i.uv.y=(i.uv.y+_Time.z*_FlowSpeed+_Offset);
                int height=i.uv.y%5;
                if(height>3)col=_Color1;
                else if(height>2)col=_Color2;
                else if(height>1)col=_Color3;
                else if(height>0)col=_Color4;
                else col=_Color5;

                return col*pow(2,_Bloom);
            }
            ENDCG
        }
        UsePass "ToolPass/ShadowCaster"
    }
}
