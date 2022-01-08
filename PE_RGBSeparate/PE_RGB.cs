using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PE_RGB : PostEffectBase
{
    [Range(0, 2)] public float amplitude;
    [Range(0, 5)] public float amount;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mat) {
            Mat.SetFloat("_Amplitude", amplitude);
            Mat.SetFloat("_Amount", amount);

            Graphics.Blit(source, destination, Mat, 0);
        }
    }
}
