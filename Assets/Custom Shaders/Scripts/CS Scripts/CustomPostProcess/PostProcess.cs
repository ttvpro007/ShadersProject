using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcess : MonoBehaviour
{
    [SerializeField] private List<Material> postProcessStack = null;
    private RenderTexture texture1 = null;
    private RenderTexture texture2 = null;

    private void Start()
    {
        //material.SetVector("_Radius", new Vector4(100f / Screen.width, 100f / Screen.height, 0, 0));

        texture1 = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Default, RenderTextureReadWrite.Default);
        texture1.enableRandomWrite = true;
        texture2 = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Default, RenderTextureReadWrite.Default);
        texture1.enableRandomWrite = true;
    }

    private void Update()
    {
        //material.SetVector("_MousePos", new Vector4(Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height, 0, 0));
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (postProcessStack.Count == 0) return;

        Graphics.Blit(source, texture1);

        foreach (Material material in postProcessStack)
        {
            Graphics.Blit(texture1, texture2, material);
            Graphics.Blit(texture2, texture1);
        }

        Graphics.Blit(texture1, destination);
    }
}
