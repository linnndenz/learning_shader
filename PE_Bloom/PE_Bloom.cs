using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class PE_Bloom : PostEffectBase
{
    //高亮部分提取阈值
    public Color colorThreshold = Color.white;
    //Bloom权值
    [Range(0.0f, 20f)]
    public float bloomFactor = 0.5f;

    [Range(0,50)]
    public int iterations;

    //采样率
    private int downSample = 1;
    private float samplerScale = 1;


    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mat) {
            RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            temp1.filterMode = FilterMode.Bilinear;
            temp2.filterMode = FilterMode.Bilinear;


            Graphics.Blit(source, temp1);

            //pass0高亮提取（进入temp2）
            Mat.SetVector("_ColorThreshold", colorThreshold);
            Graphics.Blit(temp1, temp2, Mat, 0);

            //pass1高斯模糊，借用temp1横纵模糊，最终存入temp2
            //CurMaterial.SetVector("_Offsets", new Vector4(0, samplerScale, 0, 0));
            //Graphics.Blit(temp2, temp1, CurMaterial, 1);
            //CurMaterial.SetVector("_Offsets", new Vector4(samplerScale, 0, 0, 0));
            //Graphics.Blit(temp1, temp2, CurMaterial, 1);
            //CurMaterial.SetVector("_Offsets", new Vector4(samplerScale, samplerScale, 0, 0));
            //Graphics.Blit(temp2, temp1, CurMaterial, 1);
            //CurMaterial.SetVector("_Offsets", new Vector4(samplerScale, -samplerScale, 0, 0));
            //Graphics.Blit(temp1, temp2, CurMaterial, 1);

            //横纵可控（光晕大小）迭代模糊
            //该方法会导致视觉效果上远处光晕更大
            for (int i = 0; i < iterations; i++) {
                Mat.SetFloat("_BlurSize", samplerScale * i + 1);
                Graphics.Blit(temp2, temp1, Mat, 2);
                Graphics.Blit(temp1, temp2, Mat, 3);
            }

            //temp2存入BlurTex
            Mat.SetTexture("_BlurTex", temp2);
            Mat.SetFloat("_BloomFactor", bloomFactor);

            //pass2模糊叠加
            Graphics.Blit(source, destination, Mat, 4);

            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
    }

}
