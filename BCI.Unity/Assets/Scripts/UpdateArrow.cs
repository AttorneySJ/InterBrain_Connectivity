using UnityEngine;

public class UpdateArrow : MonoBehaviour
{
	[SerializeField] private Transform target;

	private void Update()
	{
		if (target == null)
			return;
		Vector3 relativePos = target.position - transform.position;
		Quaternion rotation = Quaternion.LookRotation(relativePos);
		transform.rotation = rotation;
	}
}
