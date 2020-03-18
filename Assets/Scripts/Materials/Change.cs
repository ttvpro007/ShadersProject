using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Change : MonoBehaviour
{
    [SerializeField] private Material originalMaterial = null;
    [SerializeField] private Material outlineMaterial = null;
    [SerializeField] private PostProcess postProcess = null;
    private Renderer[] renderers = null;

    private void Start()
    {
        renderers = GetComponentsInChildren<Renderer>();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            if (postProcess.enabled)
            {
                postProcess.enabled = false;
                SetMaterial(renderers, originalMaterial);
            }
            else
            {
                postProcess.enabled = true;
                SetMaterial(renderers, outlineMaterial);
            }
        }
    }

    private void SetMaterial(Renderer[] renderers, Material material)
    {
        for (int i = 0; i < renderers.Length; i++)
        {
            renderers[i].material = material;
        }
    }
}
