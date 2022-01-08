using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PE_VerticalShake : PostEffectBase
{
    [Range(1,1000)]
    public float shakeSpeed = 50;
    [Range(0, 2)]
    public float shakeAmplitude = 1;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mat != null) {
            Mat.SetFloat("_ShakeSpeed", shakeSpeed);
            Mat.SetFloat("_ShakeAmplitude", shakeAmplitude);
            Graphics.Blit(source, destination,Mat,3);
        } else {
            Graphics.Blit(source, destination);
        }
    }
}
