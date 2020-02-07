using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShadersProject.Camera.Translation
{
    public class Rotation : MonoBehaviour
    {
        [SerializeField] private float xSpeed = 0;
        [SerializeField] private float ySpeed = 0;
        [SerializeField] private float zSpeed = 0;

        private void Update()
        {
            transform.Rotate(new Vector3(xSpeed, ySpeed, zSpeed) * Time.deltaTime);
        }
    }
}