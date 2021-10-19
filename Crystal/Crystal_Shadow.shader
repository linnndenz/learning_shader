Shader "Learning/Crystal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("Color A",Color)=(1,1,1,1)
        _ColorB("Color B",Color)=(1,1,1,1)
        _ColorOffset("Color Offset",Range(-0.5,.5))=0

        //��������
        _Ambient("Ambient Amount",Range(0,2.5))=0.8

        //...
        _NoiseTex("Noise Tex",2D)="white"{}
        //���Ͳ���
        _Amplitude("Explode Amplitude",Range(0,5))=1
        _Frequence("Explode Frequence",Range(0,12))=5
        _Explode("Explode",Range(0,3.1416))=1

        _Alpha("Alpha",Range(0,1))=0.5
        _AlphaOffset("Alpha Offset",Range(0,1))=0.5
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" "LightMode" = "ShadowCaster"}
        //Tags{"RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent"}  //͸������
        LOD 100

        Pass
        {
            Tags { "RenderType"="Opaque" "Queue"="Transparent"}
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

                //����
                float3 normal:NORMAL;
                float3 lightDir:TEXCOORD1;

                //...
                float4 crystalColor:TEXCOORD3;
                fixed alpha:TEXCOORD4;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _ColorA;
            fixed4 _ColorB;
            float _ColorOffset;

            //��������
            float _Ambient;

            //...
            sampler2D _NoiseTex;
            float _Amplitude;
            float _Frequence;
            float _Explode;

            fixed _Alpha;
            fixed _AlphaOffset;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.uv=float2(TRANSFORM_TEX(v.uv,_MainTex));

                //�������ղ�����ģ�Ϳռ䣩
                o.lightDir=normalize(ObjSpaceLightDir(v.vertex));
                o.normal=normalize(v.normal);

                //����������
                float4 noise=tex2Dlod(_NoiseTex,float4(v.uv,0,0));
	            float time = (sin(_Explode+noise.r*_Frequence)+1)*0.5;
	            //v.vertex.xyz += v.normal * noise.r * _Amplitude * time;
	            v.vertex.xyz += v.normal  * _Amplitude * time;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.crystalColor=lerp(_ColorA,_ColorB,saturate(time+_ColorOffset));
                o.alpha=lerp(_Alpha,1,saturate(1-time+_AlphaOffset));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //...
                col*=i.crystalColor;

                //Ԥ�ƹ���
                i.normal=normalize(i.normal);
                fixed3 diffuse =_LightColor0*(dot(i.normal,i.lightDir)*0.5+0.5);                           //������
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                    //������

                col*=fixed4(diffuse+ambient,i.alpha);
                return col;
            }
            ENDCG
        }

        //ͶӰ
         Pass
        {
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;

                //...
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            //...
            sampler2D _NoiseTex;
            float _Frequence;
            float _Explode;
            float _Amplitude;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);

                //����������
                float4 noise=tex2Dlod(_NoiseTex,float4(v.uv,0,0));
	            float time = (sin(_Explode+noise.r*_Frequence)+1)*0.5;
	            //v.vertex.xyz += v.normal * noise.r * _Amplitude * time;
	            v.vertex.xyz += v.normal  * _Amplitude * time;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

             fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                UNITY_INITIALIZE_OUTPUT(fixed4,col);
                return col;
            }
            ENDCG
        }

    }
}
