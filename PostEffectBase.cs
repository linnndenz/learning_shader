using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//帧缓存滤镜，挂载在主相机上
//shader关联到c#
[ExecuteInEditMode]
public class PostEffectBase : MonoBehaviour
{
    //#region name可以创建一个区块,方便折叠注释
    #region Variables
    public Shader curShader;//名字固定,自动关联
    private Material curMaterial;//临时申请释放的
    #endregion

    #region Properties
    //curMaterial的属性
    protected Material Mat
    {
        get
        {
            if (curMaterial == null && curShader!=null) {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;//临时使用的
            }
            return curMaterial;
        }
    }
    #endregion

    //子类重写这个函数
    //private void OnRenderImage(RenderTexture source, RenderTexture destination){}

    void OnDisable()
    {
        if (curMaterial) DestroyImmediate(curMaterial);
    }
}
