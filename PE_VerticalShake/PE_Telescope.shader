Shader "Unlit/PE_Telescope"
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed2 _Center;
            float _Radius;
            float _ZoomFactor;

            float4 _ScopeColor;
            float _ScopeThick;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                //ÆÁÄ»³¤¿í
                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);
                //»æÖÆÍûÔ¶¾µ¾µ±ß
                float dis = length((i.uv - _Center)*scale);
                if(dis > _Radius && dis <_Radius + _ScopeThick){
                    col = _ScopeColor;
                }
                //·Å´ó
                if(dis < _Radius){
                    fixed2 offset = (_Center - i.uv) * _ZoomFactor;
                    col = tex2D(_MainTex, i.uv + offset);
                }

                if(dis > _Radius + _ScopeThick){
                    col = lerp(col,_ScopeColor,0.85f);
                }

                return col;
            }
            ENDCG
        }
    }
}
