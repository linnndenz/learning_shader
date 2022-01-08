using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PE_Matrix : PostEffectBase
{
    [ColorUsage(true,true)]
    public Color color;
    public Texture flowingTex;
    public Texture textTex;
    public Vector4 cellSize=new Vector4(0.03f,0.04f,0.03f,0);
    public Vector4 texSizes=new Vector4(256,10,0,0);
    public Vector4 speed=new Vector4(3,5,0,0);

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mat) {
            RenderTexture temp1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            temp1.filterMode = FilterMode.Bilinear;

            Mat.SetVector("_Color", color);
            Mat.SetTexture("_FlowingTex", flowingTex);
            Mat.SetTexture("_TextTex", textTex);
            Mat.SetVector("_CellSize", cellSize);
            Mat.SetVector("_TexSizes", texSizes);
            Mat.SetVector("_Speed", speed);
            Graphics.Blit(source,temp1, Mat, 0);

            Mat.SetTexture("_MatrixTex", temp1);
            Graphics.Blit(source, destination, Mat, 1);

            //一定要回收不然能炸电脑
            RenderTexture.ReleaseTemporary(temp1);
        } else {
            Graphics.Blit(source, destination);
        }
    }
}
