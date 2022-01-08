Shader "Learning/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        //MainTexŤ��
        _MainDistrotionFactor("Main Distortion Factor",Range(0,1))=1

         //��������
         [Header(Base Light)]
        _Ambient("Ambient Amount",Range(0,2))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Amount",Range(0,200))=15

        //����
         [Header(Wave)]
        _Speed("Wave Speed",Range(0,3))=2
        _Frequence("Wave Frequence",Range(0,1))=0.5
        _Amplitude("Wave Amplitude",Range(0,5))=2

        //ˮ���Ե
         [Header(Foam)]
        _FoamThickness("Foam Tickness",Range(0.3,5)) = 0.5
        [HDR]_FoamColor("Foam Color",Color) = (1,1,1,0.5)

        //����
         [Header(Refraction)]
        _RefractMap("Refraction Distortion Map",2D)="grey"{}
        _RefracFactor("Refraction Factor",Range(0.0001,2))=1
    }
    SubShader
    {
        LOD 100
        
        //Tags { "RenderType"="Transparent" "IgnoreProject"="True" "Queue"="Transparent" }
        Tags { "RenderType"="Opaque" "Queue"="Transparent-5" "LightMode" = "ForwardBase"}
        Blend SrcAlpha OneMinusSrcAlpha

        //����ץȡ
        GrabPass{}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float2 noiseUV:TEXCOORD1;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                //����
                float3 normal:NORMAL;
                float3 lightDir:TEXCOORD2;
                float3 viewDir:TEXCOORD3;

                //ˮ���Ե
                float4 screenPos:TEXCOORD4;

                //����Ť��
                float2 refracMap :TEXCOORD5;
                float4 grabTex:TEXCOORD6;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _MainDistrotionFactor;

             //��������
            float _Ambient;
            fixed4 _SpecularColor;
            float _Gloss;

            //���˲���
            float _Speed, _Frequence, _Amplitude;

            //ˮ���Ե
            sampler2D _CameraDepthTexture;
            float _FoamThickness;
            fixed4 _FoamColor;

            //����Ť��
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            sampler2D _RefractMap;
            float4 _RefractMap_ST;
            float _RefracFactor;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                 //�������ղ�����ģ�Ϳռ䣩
                o.lightDir=normalize(ObjSpaceLightDir(v.vertex));
                o.viewDir=normalize(ObjSpaceViewDir(v.vertex));

                //���˲���
                float wave=sin(_Time.z * _Speed +(v.vertex.x * v.vertex.z * _Frequence)) * _Amplitude;
                v.vertex.y += wave;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //ˮ���Ե
                o.screenPos = ComputeScreenPos(o.vertex);

                //����Ť��
                o.refracMap=TRANSFORM_TEX(v.vertex,_RefractMap);
                o.grabTex=ComputeGrabScreenPos(o.vertex);

                //�����Ŷ�
                o.normal=v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Ԥ�ƹ���
                i.normal=normalize(i.normal);
                fixed3 diffuse =_LightColor0*(saturate(dot(i.normal,i.viewDir)));                          //������
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                    //������
                fixed3 halfDir = normalize(i.lightDir+i.viewDir);
                fixed3 specular = _LightColor0*_SpecularColor*pow(saturate(dot(i.normal,halfDir)),_Gloss); //�߹�
                //col*=fixed4(diffuse+ambient+specular,1)*_Color;

                //ˮ���Ե
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
				float depth = LinearEyeDepth(depthSample);
				float foamLine = 1 - saturate(_FoamThickness * (depth - i.screenPos.w));

                //����Ť��
                float2 refra=UnpackNormal(tex2D(_RefractMap,i.refracMap+(_Time.x*0.2)));
                float2 offset= refra * (_RefracFactor * 10) * _GrabTexture_TexelSize.xy * 10;
                i.grabTex.xy = offset + i.grabTex.xy;
                float4 refr = tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(i.grabTex));

                //Main Tex Ť��
                fixed4 col = tex2D(_MainTex, i.uv + offset * _MainDistrotionFactor / _RefracFactor);
                col = (col + refr)*_Color;
                col += foamLine * fixed4(_FoamColor.rgb,1-_FoamColor.a);
                col *=fixed4(diffuse+ambient+specular,1); 
                return col;
            }
            ENDCG
        }

        
    }
}
