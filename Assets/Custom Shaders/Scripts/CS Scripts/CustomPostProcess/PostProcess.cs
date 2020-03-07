using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcess : MonoBehaviour
{
    [SerializeField] private Material material = null;

    private void Start()
    {
        material.SetVector("_Radius", new Vector4(100f / Screen.width, 100f / Screen.height, 0, 0));
    }

    private void Update()
    {
        material.SetVector("_MousePos", new Vector4(Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height, 0, 0));
        //material.SetFloat("_MouseY", Input.mousePosition.y / Screen.height);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}
