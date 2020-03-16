using System.Collections;
using System.Collections.Generic;
using UnityEngine;

struct Particle
{
    float posX;
    float posY;
    float velX;
    float velY;
}

public class ComputeHandler : MonoBehaviour
{
    [SerializeField] private ComputeShader compute = null;
    [SerializeField] private RenderTexture renderTexture = null;
    [SerializeField] private Material material = null;
    [SerializeField] private int resolution = 1920;
    [SerializeField] private int numberOfParticles = 1024;

    private ComputeBuffer particleBuffer = null;
    private Particle[] particles = null;
    
    private void Start()
    {
        renderTexture = new RenderTexture(resolution, resolution, 24, RenderTextureFormat.Default, RenderTextureReadWrite.Default);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();
        material.SetTexture("_MainTex", renderTexture);
        
        particleBuffer = new ComputeBuffer(numberOfParticles, 4 * sizeof(float), ComputeBufferType.Default);
        particles = new Particle[numberOfParticles];

        particleBuffer.SetData(particles);

        SetUniforms();
        int kernel = compute.FindKernel("InitParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.Dispatch(kernel, numberOfParticles / 64, 1, 1);
    }
    
    private void Update()
    {
        SetUniforms();

        //int kernel = compute.FindKernel("CSMain");
        //compute.SetTexture(kernel, "Result", renderTexture);
        //compute.Dispatch(kernel, resolution / 8, resolution / 8, 1);

        int kernel = compute.FindKernel("MoveParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.Dispatch(kernel, numberOfParticles / 64, 1, 1);

        kernel = compute.FindKernel("ClearDisplay");
        compute.SetTexture(kernel, "Result", renderTexture);
        compute.Dispatch(kernel, resolution / 8, resolution / 8, 1);

        kernel = compute.FindKernel("DisplayParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.SetTexture(kernel, "Result", renderTexture);
        compute.Dispatch(kernel, numberOfParticles / 64, 1, 1);
    }

    private void SetUniforms()
    {
        compute.SetInt("numberOfParticles", numberOfParticles);
        compute.SetFloat("initialSpeed", 100f);
        compute.SetFloat("dt", Time.deltaTime);
    }
}
