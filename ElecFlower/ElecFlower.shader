Shader "Unlit/ElecFlower"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color",Color) = (1,1,1,1)
        _Range("Flower Range",Range(0,2)) = 0.1
        _Dense("Dense",Range(0,20))=5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Range;
            float _Dense;

            
            fixed Random(float2 n)
            {
                float r = sin(dot(n, half2(1233.224, 1743.335)));
                r = frac(43758.5453 * r + 0.61432);
                r = frac(43758.5453 * r + 0.61432);
                return r;
                //return frac(sin(dot(n, float2(12.9898,78.233))) * 43758.5453123);
            }

            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            [maxvertexcount(1)]
            void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream){
                g2f o;
                float3 v1 = IN[1].vertex - IN[0].vertex;
                float3 v2 = IN[2].vertex - IN[0].vertex;
                float3 normal = normalize(cross(v1,v2));

                //-1~1
                float rdx = (Random(float2(normal.x*_Time.x,2))-0.5) * 2;
                float rdy = (Random(float2(normal.y*_Time.x,2))-0.5) * 2;
                float rdz = (Random(float2(normal.z*_Time.x,2))-0.5) * 2;
               

                float3 pos = float3(rdx,rdy,rdz);
                pos = normalize(pos)* (1-log10(length(pos)*_Dense+1));
                pos *= _Range;

                o.vertex = UnityObjectToClipPos(pos);
                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                pointStream.Append(o);
            }

            float4 frag (g2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col * _Color;
            }

            ENDCG
        }
    }
}
