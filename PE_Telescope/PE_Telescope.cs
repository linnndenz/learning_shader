using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PE_Telescope : PostEffectBase
{
    public GameObject player;
    public float moveSpeed;

    [Range(0, 1)] public float radius;
    private Vector2 center = new Vector2(0.5f, 0.5f);
    [Range(0.1f,1)]
    public float maxZoomFactor;
    private float zoomFactor;

    public Color scopeColor;
    [Range(0, 1)] public float scopeThick;

    public bool bScope;

    void Start()
    {
        zoomFactor = maxZoomFactor / 2;
    }

    bool bLoosJoyUpDown;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F)||(bLoosJoyUpDown&&Input.GetAxisRaw("JoyUpDown")>0.5f)) {
            if (bScope) {//则关闭
                player.SetActive(true);
            } else {//则开启
                center = new Vector2(0.5f, 0.5f);
                player.SetActive(false);//移动脚本也一并停了
            }
            bScope = !bScope;

            bLoosJoyUpDown = false;
        }

        //解决JoyStick 7thAxis无法GetButtonDown问题
        if(Input.GetAxisRaw("JoyUpDown") < 0.5f) {
            bLoosJoyUpDown = true;
        }

        if (bScope) {
            MoveScope();
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (bScope) {
            Mat.SetVector("_Center", center);
            Mat.SetFloat("_Radius", radius);
            Mat.SetFloat("_ZoomFactor", zoomFactor);

            Mat.SetFloat("_ScopeThick", scopeThick);
            Mat.SetVector("_ScopeColor", scopeColor);

            Graphics.Blit(source, destination, Mat);
        } else {
            Graphics.Blit(source, destination);
        }
    }

    float scopeV;
    float scopeH;
    Vector2 move;
    float zoom;
    void MoveScope()
    {
        //镜头移动
        scopeV = Input.GetAxis("DirVertical");
        scopeH = Input.GetAxis("DirHorizontal");
        move = new Vector2(scopeH, scopeV);
        if (move.magnitude > 0.1f) {
            move = center + move * moveSpeed * Time.deltaTime;
            if (move.x < 0) move.x = 0;
            if (move.x > 1) move.x = 1;
            if (move.y < 0) move.y = 0;
            if (move.y > 1) move.y = 1;
            center = move;
        }

        //zoom
        zoom = Input.GetAxis("Vertical");
        if (Mathf.Abs(zoom) > 0.1f) {
            zoom = zoomFactor + zoom * Time.deltaTime;
            if (zoom < 0) zoom = 0;
            if (zoom > maxZoomFactor) zoom = maxZoomFactor;
            zoomFactor = zoom;
        }
    }
}
