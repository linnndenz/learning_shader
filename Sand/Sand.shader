// ģ�����ӻ�Ч��
Shader "Unlit/Sand"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_InitSpeed("Init Speed", Float) = 0
		_Acceleration("Acceleration", Float) = 5
        //_ContinueTime("Current Time",Int) = 2
        [HDR]_Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent-1"}
        
        Pass{
            Blend SrcAlpha OneMinusSrcAlpha 

            CGPROGRAM
            
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _InitSpeed;
            float _Acceleration;
            float _ContinueTime;
            fixed4 _Color;

            struct a2v{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct g2f{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 col :TEXCOORD1;
            };

            v2g vert(a2v v){
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                return o;
            }

            float _Timer;
            // �������������������
            [maxvertexcount(1)]
            //[maxvertexcount(4)]
            void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream){
                g2f o;
                float3 v1 = IN[1].vertex - IN[0].vertex;
                float3 v2 = IN[2].vertex - IN[0].vertex;
                float3 normal = normalize(cross(v1,v2));

                float3 pos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;//����

                //float time = _Time.y % _ContinueTime;
                pos += normal * (_InitSpeed * _Timer + 0.5 * _Acceleration * pow(_Timer, 2));

                o.vertex = UnityObjectToClipPos(pos);
                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                o.col = _Color;

                pointStream.Append(o);

                //g2f o;
                //float3 v1 = IN[1].vertex - IN[0].vertex;
                //float3 v2 = IN[2].vertex - IN[0].vertex;
                //float3 normal = normalize(cross(v1,v2));

                //float3 center = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;//����
                //float3 pos = center;

                //float time = _Time.y % _ContinueTime;
                //pos += normal * (_InitSpeed * time + 0.5 * _Acceleration * pow(time, 2));
                //o.alpha = saturate(1 - time/2); 
                //o.vertex = UnityObjectToClipPos(pos);
                //o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
                //pointStream.Append(o);

                //for(uint n = 0;n<3;n++){
                //    pos = (center + IN[n].vertex + IN[(n+1)%3].vertex) / 3;
                //    pos += normal * (_InitSpeed * time + 0.5 * _Acceleration * pow(time, 2));
                //    o.alpha = saturate(1 - time/2); 
                //    o.vertex = UnityObjectToClipPos(pos);
                //    o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
                //    pointStream.Append(o);
                //}
            }

            float4 frag (g2f i) : SV_Target
            {
                float4 col = float4(i.col,saturate(1-_Timer/2));
                return col;
            }

            ENDCG
        }
        
    }
    FallBack "Diffuse"
}

