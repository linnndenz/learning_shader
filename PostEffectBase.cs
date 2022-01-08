using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//֡�����˾����������������
//shader������c#
[ExecuteInEditMode]
public class PostEffectBase : MonoBehaviour
{
    //#region name���Դ���һ������,�����۵�ע��
    #region Variables
    public Shader curShader;//���̶ֹ�,�Զ�����
    private Material curMaterial;//��ʱ�����ͷŵ�
    #endregion

    #region Properties
    //curMaterial������
    protected Material Mat
    {
        get
        {
            if (curMaterial == null && curShader!=null) {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;//��ʱʹ�õ�
            }
            return curMaterial;
        }
    }
    #endregion

    //������д�������
    //private void OnRenderImage(RenderTexture source, RenderTexture destination){}

    void OnDisable()
    {
        if (curMaterial) DestroyImmediate(curMaterial);
    }
}
