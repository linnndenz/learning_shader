using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PE_SceneScan : PostEffectBase
{
    private Camera myCamera;

    [Range(0, 0.2f)] public float velocity = 0.05f;
    [Range(0, 5)] public float continueTime = 3;
    private bool bScanning;
    private float dis;
    private bool bEnding;
    private float scanEnd;

    [ColorUsage(true, true)] public Color lineColor;
    [ColorUsage(true, true)] public Color scanColor;
    [Range(0, 0.1f)] public float scanWidth;
    public float lineNum;
    public float gap;


    void Start()
    {
        myCamera = GetComponent<Camera>();
        myCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    float timer;
    void Update()
    {
        //Ω· ¯…®√Ë
        if (bEnding) {
            if (timer > continueTime*2) {
                bEnding = false;
            } else {
                timer += Time.deltaTime;
            }
            scanEnd += Time.deltaTime * velocity * gap * 2;
            dis += Time.deltaTime * velocity;
        }
        //…®√Ë
        if (bScanning) {
            if (timer >= continueTime) {
                timer = 0;
                bEnding = true;
                bScanning = false;
            } else {
                timer += Time.deltaTime;
            }
            dis += Time.deltaTime * velocity;
        }

        //ºÏ≤‚…®√Ë
        if (Input.GetKeyDown(KeyCode.C) || Input.GetKeyDown(KeyCode.JoystickButton3)) {
            dis = 0;
            scanEnd = 0;
            timer = 0;
            bEnding = false;
            bScanning = true;
        }

    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (bScanning || bEnding) {
            Mat.SetFloat("_ScanDistance", dis);
            Mat.SetFloat("_ScanEnd", scanEnd);
            Mat.SetFloat("_ScanWidth", scanWidth);

            Mat.SetFloat("_LineNum", lineNum);
            Mat.SetFloat("_Gap", gap);

            Mat.SetColor("_LineColor", lineColor);
            Mat.SetColor("_ScanColor", scanColor);
            Graphics.Blit(source, destination, Mat);
        } else {
            Graphics.Blit(source, destination);
        }
    }
}
