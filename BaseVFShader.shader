Shader "Unlit/BaseVFShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //��������
        _Ambient("Ambient Amount",Range(0,1))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Amount",Range(0,200))=15

        //...
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags{"RenderType"="Transparent" "Queue"="Transparent"}  //͸������

        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha                     //͸������

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

                fixed4 diffuse:COLOR0;
                fixed4 specular:COLOR1;

                //...
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            //��������
            float _Ambient;
            fixed4 _SpecularColor;
            float _Gloss;

            //...

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Ԥ�ƹ���
                    //half-lambert
                float3 worldNormal=UnityObjectToWorldNormal(v.normal);
                float3 lightDir=normalize(_WorldSpaceLightPos0);
                o.diffuse=_LightColor0*(dot(worldNormal,lightDir)*0.5+0.5);
                    //blinn-phong
                float3 viewDir=normalize(WorldSpaceViewDir(v.vertex));
                float3 halfDir=normalize(lightDir+viewDir);
                o.specular=_LightColor0*_SpecularColor*pow(max(0,dot(worldNormal,halfDir)),_Gloss);

                //...

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //...

                //Ԥ�ƹ���
                fixed3 baseColor=i.diffuse.rgb;                     //������
                baseColor+=UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;   //������
                baseColor+=i.specular;                              //�߹�
                baseColor*=_Color.rgb;

                return col*fixed4(baseColor,_Color.a);
            }
            ENDCG
        }
    }
}
