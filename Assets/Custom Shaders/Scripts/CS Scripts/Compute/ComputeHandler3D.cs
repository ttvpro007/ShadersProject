using System.Collections;
using System.Collections.Generic;
using UnityEngine;

struct Particle3D
{
    float posX;
    float posY;
    float posZ;
    float velX;
    float velY;
    float velZ;
    float life;
};

public class ComputeHandler3D : MonoBehaviour
{
    [SerializeField] private ComputeShader compute = null;
    [SerializeField] private Material material = null;
    [SerializeField] private Transform spawnPoint = null;
    [SerializeField] private float boundary = 50f;
    [SerializeField] private int numberOfParticles = 1024;
    [SerializeField] private int numberOfBatches = 0;
    [SerializeField] private int numberOfRings = 0;
    [SerializeField] private float spawnTimeInterval = 0;
    [SerializeField] private LayerMask hitLayer = 0;

    private int kernel = 0;
    private int batchSize = 0;
    private int batchID = 0;
    private float batchTimer = 0;
    private ComputeBuffer particleBuffer = null;
    private Particle3D[] particles = null;
    private Camera cam = null;
    
    private void Start()
    {
        particleBuffer = new ComputeBuffer(numberOfParticles, 7 * sizeof(float), ComputeBufferType.Default);
        particles = new Particle3D[numberOfParticles];
        particleBuffer.SetData(particles);

        material.SetBuffer("particleBuffer", particleBuffer);
        material.SetFloat("_MaxLife", 5f);

        batchSize = numberOfParticles / numberOfBatches;

        SetUniforms();
        kernel = compute.FindKernel("InitParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.Dispatch(kernel, batchSize / 64, 1, 1);
        cam = Camera.main;
    }
    
    private void Update()
    {
        SetUniforms();

        //int kernel = compute.FindKernel("CSMain");
        //compute.SetTexture(kernel, "Result", renderTexture);
        //compute.Dispatch(kernel, resolution / 8, resolution / 8, 1);

        kernel = compute.FindKernel("MoveParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.Dispatch(kernel, numberOfParticles / 64, 1, 1);

        batchTimer += Time.deltaTime;

        if (batchTimer > spawnTimeInterval)
        {
            batchID += batchSize;
            batchID = batchID % numberOfParticles;
            SetUniforms();
            kernel = compute.FindKernel("InitParticles");
            compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
            compute.Dispatch(kernel, batchSize / 64, 1, 1);
            batchTimer = 0;
        }
    }

    private void OnRenderObject()
    {
        material.SetPass(0);
        Graphics.DrawProcedural(
            material, 
            new Bounds(transform.position, new Vector3(boundary, boundary, boundary)), 
            MeshTopology.Points, 
            1, 
            numberOfParticles);
    }

    private void SetUniforms()
    {
        compute.SetInt("numberOfParticles", numberOfParticles);
        compute.SetInt("batchID", batchID);
        compute.SetInt("batchSize", batchSize / numberOfRings);
        compute.SetInt("numberOfRings", numberOfRings);

        compute.SetFloat("posX", spawnPoint.position.x);
        compute.SetFloat("posY", spawnPoint.position.y);
        compute.SetFloat("posZ", spawnPoint.position.z);

        compute.SetFloat("boundary", boundary);
        compute.SetFloat("initialSpeed", 50f);
        compute.SetFloat("verticalAcceleration", -10f);
        compute.SetFloat("maxLife", 5f);
        compute.SetFloat("dt", Time.deltaTime);
    }
}
