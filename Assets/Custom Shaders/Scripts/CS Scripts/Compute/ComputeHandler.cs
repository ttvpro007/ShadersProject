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
    [SerializeField] private Material material = null;
    [SerializeField] private int resolution = 1920;
    [SerializeField] private int numberOfParticles = 1024;
    [SerializeField] private int numberOfBatches = 0;
    [SerializeField] private float spawnTimeInterval = 0;
    [SerializeField] private LayerMask hitLayer = 0;
    [SerializeField] private ObstacleInfo obstacleInfo;

    private int kernel = 0;
    private int batchSize = 0;
    private int batchID = 0;
    private float batchTimer = Mathf.Infinity;
    private float x = 0;
    private float y = 0;
    private RenderTexture renderTexture = null;
    private ComputeBuffer particleBuffer = null;
    private Particle[] particles = null;
    private Camera cam = null;
    
    private void Start()
    {
        renderTexture = new RenderTexture(resolution, resolution, 24, RenderTextureFormat.Default, RenderTextureReadWrite.Default);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();
        material.SetTexture("_MainTex", renderTexture);
        
        particleBuffer = new ComputeBuffer(numberOfParticles, 4 * sizeof(float), ComputeBufferType.Default);
        particles = new Particle[numberOfParticles];

        particleBuffer.SetData(particles);

        batchSize = numberOfParticles / numberOfBatches;

        SetUniforms();
        kernel = compute.FindKernel("InitParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.Dispatch(kernel, batchSize / 64, 1, 1);
        cam = Camera.main;
    }
    
    private void Update()
    {
        RaycastHit hit;

        if (Input.GetMouseButtonDown(0))
        {
            if (Physics.Raycast(cam.ScreenPointToRay(Input.mousePosition), out hit, hitLayer))
            {
                Debug.DrawLine(cam.transform.position, hit.point - cam.transform.position, Color.white, 100f);
                Vector3 delta = hit.point - transform.position;
                x = (delta.x + transform.localScale.x * 0.5f) * resolution / transform.localScale.x;
                y = (delta.y + transform.localScale.y * 0.5f) * resolution / transform.localScale.y;
                compute.SetFloat("mousePosX", x);
                compute.SetFloat("mousePosY", y);
            }
        }

        SetUniforms();

        //int kernel = compute.FindKernel("CSMain");
        //compute.SetTexture(kernel, "Result", renderTexture);
        //compute.Dispatch(kernel, resolution / 8, resolution / 8, 1);

        kernel = compute.FindKernel("MoveParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.Dispatch(kernel, numberOfParticles / 64, 1, 1);

        kernel = compute.FindKernel("ClearDisplay");
        compute.SetTexture(kernel, "Result", renderTexture);
        compute.Dispatch(kernel, resolution / 8, resolution / 8, 1);

        kernel = compute.FindKernel("DisplayParticles");
        compute.SetBuffer(kernel, "particleBuffer", particleBuffer);
        compute.SetTexture(kernel, "Result", renderTexture);
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

    private void SetUniforms()
    {
        compute.SetInt("numberOfParticles", numberOfParticles);
        compute.SetInt("batchID", batchID);
        compute.SetInt("batchSize", batchSize);
        compute.SetFloat("initialSpeed", 100f);
        compute.SetFloat("verticalAcceleration", -50f);
        compute.SetFloat("dt", Time.deltaTime);
        UpdateObstacleInfo();
    }

    private void OnValidate()
    {
        UpdateObstacleInfo();
    }

    private void UpdateObstacleInfo()
    {
        obstacleInfo.scale = obstacleInfo.transform.localScale;
        obstacleInfo.position = obstacleInfo.transform.position;
        Vector3 delta = obstacleInfo.position - transform.position;
        obstacleInfo.wallXMin = (delta.x - obstacleInfo.scale.x * 0.5f + transform.localScale.x * 0.5f) * resolution / transform.localScale.x;
        obstacleInfo.wallXMax = (delta.x + obstacleInfo.scale.x * 0.5f + transform.localScale.x * 0.5f) * resolution / transform.localScale.x;
        obstacleInfo.wallYMin = (delta.y - obstacleInfo.scale.y * 0.5f + transform.localScale.y * 0.5f) * resolution / transform.localScale.y;
        obstacleInfo.wallYMax = (delta.y + obstacleInfo.scale.y * 0.5f + transform.localScale.y * 0.5f) * resolution / transform.localScale.y;
        compute.SetFloat("wallXMin", obstacleInfo.wallXMin);
        compute.SetFloat("wallXMax", obstacleInfo.wallXMax);
        compute.SetFloat("wallYMin", obstacleInfo.wallYMin);
        compute.SetFloat("wallYMax", obstacleInfo.wallYMax);
        compute.SetFloat("wallThickness", obstacleInfo.wallThickness);
    }
}
