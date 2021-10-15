Shader "Learning/BaseVFShader_Bump"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //������ͼ
        _BumpMap("Bump(Normal) Map",2D)="bump"{}
        _BumpScale("Bump Scale",Range(0,3))=1
        //��������
        _Ambient("Ambient Amount",Range(0,1))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Amount",Range(0,80))=15

        //...
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags{"RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent"}  //͸������

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
                float4 tangent:TANGENT;
                float2 bumpUV:TEXCOORD1;

                //...
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float2 bumpUV:TEXCOORD1;
                float3 lightDir:TEXCOORD2;
                float3 viewDir:TEXCOORD3;
                //...
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            //������ͼ
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

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
                o.uv=float2(TRANSFORM_TEX(v.uv,_MainTex));

                //Ӧ�÷�����ͼ
                o.bumpUV=float2(TRANSFORM_TEX(v.bumpUV,_BumpMap));
                TANGENT_SPACE_ROTATION; //ģ�Ϳռ�->���߿ռ䣨����frag�ļ��㶼�������߿ռ��£���Ҫ�õ�tangent������rotation����
                o.lightDir=normalize(mul(rotation,ObjSpaceLightDir(v.vertex)));
                o.viewDir=normalize(mul(rotation,ObjSpaceViewDir(v.vertex)));
                
                //...

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //...
                
                //����ȷ��
                fixed3 tangentNormal=UnpackNormal(tex2D(_BumpMap,i.bumpUV));
                tangentNormal.xy*=_BumpScale;
                tangentNormal=normalize(tangentNormal);
                //Ԥ�ƹ���
                fixed3 diffuse =_LightColor0*(dot(tangentNormal,i.lightDir)*0.5+0.5);                           //������
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                         //������
                fixed3 halfDir = normalize(i.lightDir+i.viewDir);
                fixed3 specular = _LightColor0*_SpecularColor*pow(saturate(dot(tangentNormal,halfDir)),_Gloss); //�߹�

                col*=fixed4(diffuse+ambient+specular,1)*_Color;
                return col;
            }
            ENDCG
        }
    }
}
