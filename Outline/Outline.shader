Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //基础光照
        _Ambient("Ambient Amount",Range(0,1))=0.8

        //描边
        _OutlineWidth("Outline Width",Range(0,0.2))=0.1
        [HDR]_OutlineColor("Outline Color",Color)=(1,1,1,1)
        _V2N("Model to Normal",Range(0,1))=0.5
    }
    SubShader
    {
        Pass
        {
			Cull Front
			Offset 1,1

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _OutlineWidth;
            float4 _OutlineColor;
            fixed _V2N;

             struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);

                //进行手动插值，面数少而简单的模型用顶点外扩（会因几何中心而偏移），精而复杂的用法线外扩（会断线）
                v.vertex.xyz += lerp(normalize(v.vertex.xyz),v.normal,_V2N) * _OutlineWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal:NORMAL;
                //...
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                //光照
                float3 normal:NORMAL;
                float3 lightDir:TEXCOORD1;
                float3 viewDir:TEXCOORD2;

                //...
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            //基础光照
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=float2(TRANSFORM_TEX(v.uv,_MainTex));

                //基础光照参数（模型空间）
                o.lightDir=normalize(ObjSpaceLightDir(v.vertex));
                o.normal=normalize(v.normal);
                //...

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //...
                
                //预制光照
                fixed3 diffuse =_LightColor0*(dot(i.normal,i.lightDir)*0.5+0.5);                           //漫反射
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                    //环境光

                col*=fixed4(diffuse+ambient,1)*_Color;
                return col;
            }
            ENDCG
        }
        UsePass "ToolPass/ShadowCaster"

    }
}
