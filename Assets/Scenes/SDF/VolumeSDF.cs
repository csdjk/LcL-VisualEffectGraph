using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

[ExecuteInEditMode]
public class VolumeSDF : MonoBehaviour
{
    public VisualEffect appleVisualEffect;
    public Transform spawnCube;
    public Transform modelCollider;
    public Vector3 size = new Vector3(10,10,10);
    public Transform planeCollider;

    void Update()
    {
        if(appleVisualEffect == null || spawnCube == null)
            return;
        appleVisualEffect.SetVector3("SpawnPosition", spawnCube.position);
        appleVisualEffect.SetVector3("SpawnScale", spawnCube.localScale);
        appleVisualEffect.SetVector3("CollidePosition", modelCollider.position);
        appleVisualEffect.SetVector3("CollideAngles", modelCollider.eulerAngles);
        appleVisualEffect.SetVector3("CollideSize", size);
        appleVisualEffect.SetVector3("PlaneCollidePosition", planeCollider.position);
    }
}
