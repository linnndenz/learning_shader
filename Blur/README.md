## 尝试使用不同的卷积方式
### 1、邻近八向的简单卷积
```c#
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
```
效果：![simple8](https://github.com/lizzzeeeden/learning_shader/blob/main/Blur/simple8.png)  

### 2、分别对横纵进行的一维卷积
```c#
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
```
效果：![VH](https://github.com/lizzzeeeden/learning_shader/blob/main/Blur/VH.png)  

### 3、混合前两种方法进行4向卷积  
```c#
fixed4 col = (SimpleBlur(i.uv_grab)
    +SimpleBlur(i.uv_grab+float4(_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-_Offset,0,0,0))
    +SimpleBlur(i.uv_grab+float4(2*_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-2*_Offset,0,0,0))
    +SimpleBlur(i.uv_grab+float4(3*_Offset,0,0,0))+SimpleBlur(i.uv_grab+float4(-3*_Offset,0,0,0))

    +SimpleBlur(i.uv_grab+float4(0,_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-_Offset,0,0))
    +SimpleBlur(i.uv_grab+float4(0,2*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-2*_Offset,0,0))
    +SimpleBlur(i.uv_grab+float4(0,3*_Offset,0,0))+SimpleBlur(i.uv_grab+float4(0,-3*_Offset,0,0))
)/13;
```
效果：![mix4](https://github.com/lizzzeeeden/learning_shader/blob/main/Blur/mix4.png)

### 4、改成8向卷积
```c#
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
```
效果：![mix8](https://github.com/lizzzeeeden/learning_shader/blob/main/Blur/mix8.png)  
