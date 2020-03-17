using UnityEngine;

[System.Serializable]
struct ObstacleInfo
{
    public Transform transform;
    public Vector3 position;
    public Vector3 scale;
    public float wallXMin;
    public float wallXMax;
    public float wallYMin;
    public float wallYMax;
    public float wallThickness;
}