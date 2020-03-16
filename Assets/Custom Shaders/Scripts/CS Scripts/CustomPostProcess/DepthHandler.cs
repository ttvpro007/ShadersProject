using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthHandler : MonoBehaviour
{
    private Camera camera = null;

    private void Start()
    {
        camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth;
    }
}
