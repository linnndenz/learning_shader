Shader "Learning/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        //MainTex扭曲
        _MainDistrotionFactor("Main Distortion Factor",Range(0,1))=1

         //基础光照
         [Header(Base Light)]
        _Ambient("Ambient Amount",Range(0,2))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Amount",Range(0,200))=15

        //海浪
         [Header(Wave)]
        _Speed("Wave Speed",Range(0,3))=2
        _Frequence("Wave Frequence",Range(0,1))=0.5
        _Amplitude("Wave Amplitude",Range(0,5))=2

        //水体边缘
         [Header(Foam)]
        _FoamThickness("Foam Tickness",Range(0.3,5)) = 0.5
        [HDR]_FoamColor("Foam Color",Color) = (1,1,1,0.5)

        //折射
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

        //折射抓取
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

                //光照
                float3 normal:NORMAL;
                float3 lightDir:TEXCOORD2;
                float3 viewDir:TEXCOORD3;

                //水体边缘
                float4 screenPos:TEXCOORD4;

                //折射扭曲
                float2 refracMap :TEXCOORD5;
                float4 grabTex:TEXCOORD6;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _MainDistrotionFactor;

             //基础光照
            float _Ambient;
            fixed4 _SpecularColor;
            float _Gloss;

            //海浪波动
            float _Speed, _Frequence, _Amplitude;

            //水体边缘
            sampler2D _CameraDepthTexture;
            float _FoamThickness;
            fixed4 _FoamColor;

            //折射扭曲
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

                 //基础光照参数（模型空间）
                o.lightDir=normalize(ObjSpaceLightDir(v.vertex));
                o.viewDir=normalize(ObjSpaceViewDir(v.vertex));

                //海浪波动
                float wave=sin(_Time.z * _Speed +(v.vertex.x * v.vertex.z * _Frequence)) * _Amplitude;
                v.vertex.y += wave;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //水体边缘
                o.screenPos = ComputeScreenPos(o.vertex);

                //折射扭曲
                o.refracMap=TRANSFORM_TEX(v.vertex,_RefractMap);
                o.grabTex=ComputeGrabScreenPos(o.vertex);

                //法线扰动
                o.normal=v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //预制光照
                i.normal=normalize(i.normal);
                fixed3 diffuse =_LightColor0*(saturate(dot(i.normal,i.viewDir)));                          //漫反射
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                    //环境光
                fixed3 halfDir = normalize(i.lightDir+i.viewDir);
                fixed3 specular = _LightColor0*_SpecularColor*pow(saturate(dot(i.normal,halfDir)),_Gloss); //高光
                //col*=fixed4(diffuse+ambient+specular,1)*_Color;

                //水体边缘
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
				float depth = LinearEyeDepth(depthSample);
				float foamLine = 1 - saturate(_FoamThickness * (depth - i.screenPos.w));

                //折射扭曲
                float2 refra=UnpackNormal(tex2D(_RefractMap,i.refracMap+(_Time.x*0.2)));
                float2 offset= refra * (_RefracFactor * 10) * _GrabTexture_TexelSize.xy * 10;
                i.grabTex.xy = offset + i.grabTex.xy;
                float4 refr = tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(i.grabTex));

                //Main Tex 扭曲
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
