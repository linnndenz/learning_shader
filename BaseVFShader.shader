// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BaseVFShader"
{
    Properties
    {
        _MainTexture ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //基础光照
        _Ambient("Ambient Amount",Range(0,1))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Range",Range(0,80))=15
        _GlossIntensity("Gloss(Specular) Amount",Range(0,2))=1

        //...
    }
    SubShader
    {
        //要产生投影，ForwardBase很重要，tags不能写在pass里，是subsahder的属性
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
        //Tags{"RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent-1"}  //透明设置

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
                float3 normal:NORMAL;

                //...
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;//为了接收投影，名字不变

                //光照
                float3 worldNormal:TEXCOORD1;

                //接收阴影
                float3 worldPos:TEXCOORD2;
		        SHADOW_COORDS(3)

                //...
            };

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            fixed4 _Color;

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
                o.uv=TRANSFORM_TEX(v.uv,_MainTexture);

                //基础光照参数（模型空间）+ 投影
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o);

                //...

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //...
                
                //预制光照
                fixed3 worldNormal = normalize(i.worldNormal);//世界空间下顶点法线
			    fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);//世界空间下顶点处的入射光
                fixed3 diffuse =_LightColor0*(dot(i.worldNormal,worldLight)*0.5+0.5);                           //漫反射
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                    //环境光
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLight+viewDir);
                fixed3 specular = _LightColor0*_SpecularColor*pow(saturate(dot(i.worldNormal,halfDir)),_Gloss)*_GlossIntensity; //高光

                //接收阴影
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                //着色
                fixed4 col = tex2D(_MainTexture, i.uv);
                col*=fixed4(ambient+(diffuse+specular)*atten,1)*_Color;
                return col;
            }
            ENDCG
        }

        UsePass "ToolPass/ForwardAdd"
        UsePass "ToolPass/ShadowCaster"
    }
    FallBack "Diffuse"
}
