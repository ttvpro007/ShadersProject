using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScanHandler : MonoBehaviour
{
    [SerializeField] private Material material = null;
    [SerializeField] private Camera camera = null;

    // Start is called before the first frame update
    void Start()
    {
        if (!camera) camera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            if (Physics.Raycast(camera.ScreenPointToRay(Input.mousePosition), out hit, 1000))
            {
                material.SetInt("_Active", 1);
                material.SetVector("_PlayerPos", hit.point);
                material.SetMatrix("_ViewProjectionInverse", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);
            }
        }
        else if (Input.GetMouseButtonUp(0))
        {
            material.SetInt("_Active", 0);
        }
    }
}
