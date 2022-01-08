using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PE_BlackWhite : PostEffectBase
{
    public Color colorA;
    public Color colorB;
    public float threshold;
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Mat.SetFloat("_Threshold", threshold);
        Mat.SetColor("_ColorA", colorA);
        Mat.SetColor("_ColorB", colorB);
        Graphics.Blit(source, destination, Mat);
    }
}
