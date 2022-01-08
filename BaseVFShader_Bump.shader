Shader "Unlit/BaseVFShader_Bump"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //法线贴图
        _BumpMap("Bump(Normal) Map",2D)="bump"{}
        _BumpScale("Bump Scale",Range(0,3))=1
        //基础光照
        _Ambient("Ambient Amount",Range(0,1))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Range",Range(0,80))=15
        _GlossIntensity("Gloss(Specular) Amount",Range(0,2))=1

        //...
    }
    SubShader
    {
        //Name "NormalBump"
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
        //Tags{"RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent-1"}  //透明设置

        LOD 100

        Pass
        {
            //Blend SrcAlpha OneMinusSrcAlpha                     //透明设置

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                //法线相关
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 bumpUV:TEXCOORD1;

                //...
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;

                //法线相关
                float2 bumpUV:TEXCOORD1;
                float3 lightDir:TEXCOORD2;
                float3 viewDir:TEXCOORD3;

                //接收阴影
                float3 worldPos:TEXCOORD4;
		        SHADOW_COORDS(5)

                //...
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            //法线贴图
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            //基础光照
            float _Ambient;
            fixed4 _SpecularColor;
            float _Gloss;
            float _GlossIntensity;

            //...

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.uv,_MainTex);

                //产生阴影
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o);

                //应用法线贴图
                o.bumpUV=TRANSFORM_TEX(v.bumpUV,_BumpMap);
                TANGENT_SPACE_ROTATION; //模型空间->切线空间（后续frag的计算都是在切线空间下）需要用到tangent，生成rotation矩阵
                o.lightDir=normalize(mul(rotation,ObjSpaceLightDir(v.vertex)));
                o.viewDir=normalize(mul(rotation,ObjSpaceViewDir(v.vertex)));
                
                //...

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //...
                
                //法线确认
                fixed3 tangentNormal=UnpackNormal(tex2D(_BumpMap,i.bumpUV));
                tangentNormal.xy*=_BumpScale;
                tangentNormal=normalize(tangentNormal);
                //预制光照
                fixed3 diffuse =_LightColor0*(dot(tangentNormal,i.lightDir)*0.5+0.5);                           //漫反射
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                         //环境光
                fixed3 halfDir = normalize(i.lightDir+i.viewDir);
                fixed3 specular = _LightColor0*_SpecularColor*pow(saturate(dot(tangentNormal,halfDir)),_Gloss)*_GlossIntensity; //高光

                //接收阴影
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                col*=fixed4(ambient+(diffuse+specular)*atten,1)*_Color;
                return col;
            }
            ENDCG
        }

        UsePass "ToolPass/ForwardAdd"
        UsePass "ToolPass/ShadowCaster"
    }
}
