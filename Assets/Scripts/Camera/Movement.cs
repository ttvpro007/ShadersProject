using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShadersProject.Camera.Translation
{
    public enum MovementType
    {
        TwoDimension,
        ThreeDimension
    }

    public enum PlaneDimension
    {
        XY,
        XZ,
        YZ
    }

    public class Movement : MonoBehaviour
    {
        [SerializeField] private bool move = true;
        [SerializeField] private MovementType type;
        [SerializeField] private PlaneDimension plane;
        [SerializeField] private float xSpeed = 0f;
        [SerializeField] private float ySpeed = 0f;
        [SerializeField] private float zSpeed = 0f;
        [SerializeField] private bool random = false;
        [SerializeField] private float minSpeed = 0f;
        [SerializeField] private float maxSpeed = 0f;
        [SerializeField] private float changeDirectionInterval = 0f;
        [SerializeField] private bool bound = false;
        [SerializeField] private Transform targetBound = null;
        private float xMin = 0f;
        private float xMax = 0f;
        private float yMin = 0f;
        private float yMax = 0f;
        private float changeDirectionTimer = Mathf.Infinity;

        private void Start()
        {
            if (targetBound) SetBoundary();
        }

        private void Update()
        {
            if (!move) return;

            changeDirectionTimer += Time.deltaTime;

            if (random)
            {
                if (changeDirectionTimer >= changeDirectionInterval)
                {
                    xSpeed = Random.Range(minSpeed, maxSpeed);
                    ySpeed = Random.Range(minSpeed, maxSpeed);
                    zSpeed = Random.Range(minSpeed, maxSpeed);

                    changeDirectionTimer = 0f;
                }
            }

            switch (type)
            {
                case MovementType.TwoDimension:
                    SetTwoDimensionSpeed();
                    break;
                case MovementType.ThreeDimension:
                    break;
            }

            if (bound) SetBoundarySpeed();

            transform.Translate(new Vector3(xSpeed, ySpeed, zSpeed) * Time.deltaTime);
        }

        private void SetTwoDimensionSpeed()
        {
            switch (plane)
            {
                case PlaneDimension.XY:
                    zSpeed = 0f;
                    break;
                case PlaneDimension.XZ:
                    ySpeed = 0f;
                    break;
                case PlaneDimension.YZ:
                    xSpeed = 0f;
                    break;
                default:
                    break;
            }
        }

        private void SetBoundarySpeed()
        {
            if (transform.position.x <= xMin && xSpeed < 0 ||
                transform.position.x >= xMax && xSpeed > 0)
            {
                xSpeed *= -1;
            }
            if (transform.position.y <= yMin && ySpeed < 0 ||
                transform.position.y >= yMax && ySpeed > 0)
            {
                ySpeed *= -1;
            }
        }

        private void SetBoundary()
        {
            Vector3 delta = targetBound.position - transform.position;
            xMin = delta.x - targetBound.localScale.x * 0.5f + transform.localScale.x + transform.position.x;
            xMax = delta.x + targetBound.localScale.x * 0.5f - transform.localScale.x + transform.position.x;
            yMin = delta.y - targetBound.localScale.y * 0.5f + transform.localScale.y + transform.position.y;
            yMax = delta.y + targetBound.localScale.y * 0.5f - transform.localScale.y + transform.position.y;
        }
    }
}