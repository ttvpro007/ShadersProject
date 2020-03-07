using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthHandler : MonoBehaviour
{
    [SerializeField] private Material material = null;

    private void Start()
    {
        material.SetVector("_PlayerPos", transform.position);
    }

    private void Update()
    {
        //if (Input.GetMouseButtonDown(0))
        {
            material.SetMatrix("_InverseViewMatrix", Camera.main.cameraToWorldMatrix);
            material.SetMatrix("_InverseProjectionMatrix", Camera.main.projectionMatrix.inverse);
        }
    }
}
