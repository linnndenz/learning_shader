Shader "Unlit/Grab_Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        
        //模糊
        _Blur("Blur",Range(0,1)) = 0.01
        _Offset("Offset",Range(0,0.2))=0.01
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend One OneMinusSrcAlpha

        GrabPass{}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                //抓屏
                float4 uv_grab : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            sampler2D _GrabTexture;
            float _Blur;
            float _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //抓屏
                o.uv_grab = ComputeGrabScreenPos(o.vertex);
                return o;
            }
            
            

            //模糊函数
            fixed4 SimpleBlur(float4 uv_grab){
                float offset = _Blur * _Offset;
                //float offset = _Blur * 0.0625;
                //左上
                fixed4 col = tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(-offset,offset,0,0)))*0.0947416;
                //上
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,offset,0,0)))*0.118318;
                //右上
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(offset,offset,0,0)))*0.0947416;
                //左
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(-offset,0,0,0)))*0.118318;
                //中
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab))*0.147761;
                //右
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(offset,0,0,0)))*0.11831;
                //左下 
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(-offset,-offset,0,0)))*0.0947416;
                //下
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,-offset,0,0)))*0.118318;
                //右下
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(offset,-offset,0,0)))*0.0947416;

                return col;
            }

            fixed4 VerticalBlur(float4 uv_grab){
                //float offset = _Blur * 0.0625;
                float offset = _Blur * _Offset;
                fixed4 col=fixed4(0,0,0,0);
                //纵向卷积
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,-offset,0,0)))*0.05;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,offset,0,0)))*0.05;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,-2*offset,0,0)))*0.1;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,2*offset,0,0)))*0.1;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,-3*offset,0,0)))*0.15;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(0,3*offset,0,0)))*0.15;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab))*0.4;

                return col;
            }
            fixed4 HorizontalBlur(float4 uv_grab){
                //float offset = _Blur * 0.0625;
                float offset = _Blur * _Offset;
                fixed4 col=fixed4(0,0,0,0);
                //横向卷积
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(-offset,0,0,0)))*0.05;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(offset,0,0,0)))*0.05;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(-2*offset,0,0,0)))*0.1;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(2*offset,0,0,0)))*0.1;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(-3*offset,0,0,0)))*0.15;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab+float4(3*offset,0,0,0)))*0.15;
                col += tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(uv_grab))*0.4;

                return col;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);
                //fixed4 col = SimpleBlur(i.uv_grab);

                //模糊（4向）
                //fixed4 col = (SimpleBlur(i.uv_grab)
                //    +SimpleBlur(i.uv_grab+float4(_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-_Offset,0,0,0))
                //    +SimpleBlur(i.uv_grab+float4(2*_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-2*_Offset,0,0,0))
                //    +SimpleBlur(i.uv_grab+float4(3*_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-3*_Offset,0,0,0))

                //    +SimpleBlur(i.uv_grab+float4(0,_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-_Offset,0,0))
                //    +SimpleBlur(i.uv_grab+float4(0,2*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-2*_Offset,0,0))
                //    +SimpleBlur(i.uv_grab+float4(0,3*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-3*_Offset,0,0))
                //)/12;

                //模糊（8向）
                fixed4 col = SimpleBlur(i.uv_grab);
                int times=5;
                int n=1;
                for(;n<=times;n++){
                    col += SimpleBlur(i.uv_grab+float4(n*_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-n*_Offset,0,0,0));
                }
                for(n=1;n<=times;n++){
                    col += SimpleBlur(i.uv_grab+float4(0,n*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-n*_Offset,0,0));
                }
                for(n=1;n<=times;n++){
                    col += SimpleBlur(i.uv_grab+float4(n*_Offset,n*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(-n*_Offset,-n*_Offset,0,0));
                }
                for(n=1;n<=times;n++){
                    col += SimpleBlur(i.uv_grab+float4(n*_Offset,-n*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(-n*_Offset,n*_Offset,0,0));
                }
                col/=(times*8+1);

                //横纵叠加（4向）
                //fixed4 col = VerticalBlur(i.uv_grab);
                //col += HorizontalBlur(i.uv_grab);
                //col/=2;

                col+=_Color*_Color.a;
                return col;
            }

            ENDCG
        }
    }
}
