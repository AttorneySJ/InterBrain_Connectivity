using System;
using UnityEngine;
using UnityEngine.UI;

public class Player : MatlabFunctions
{
	[Header("Player Information")]
	public int playerID;

	[Header("Movement")]
	[SerializeField] private float speed;
	[SerializeField] private float xMov;
	[SerializeField] private float zMov;

	[Header("Player Objects")]
	[SerializeField] private GameObject compass;
	[SerializeField] private SpriteRenderer cursor;
	[SerializeField] private GameObject flicker;
	[SerializeField] private GameObject UIFeedback;
	[SerializeField] private Text feedback;
	[SerializeField] private Text score;
    
    private MeshRenderer[] mr;
	private int v1;

	[Header("Player Performance")]
	[SerializeField] private ProcessManager manager;
	[SerializeField] private Transform target;
	private int criticalDist = 5;
	public int hit = 0;
	public float time;
	public float dist;
	private bool evaluated = false;

	private void Awake()
	{
		speed = 0.15f;
		mr = flicker.GetComponentsInChildren<MeshRenderer>();
		compass.SetActive(false);
		flicker.SetActive(false);
		UIFeedback.SetActive(false);
	}

	private void OnEnable()
	{
		// Reset position
		PortAccess.Output(Port.port[1], 0);
		transform.position = Vector3.zero;
		// Test
		if (manager.TRIAL >= N.trialsBlock)
		{
			cursor.sprite = manager.CursorCol[manager.taskType];
			compass.SetActive(true);
		}

		hit = 0;
        xMov = zMov = 0;
		evaluated = false;
	}

	private void OnDisable()
	{
		UIFeedback.SetActive(false);
		flicker.SetActive(false);
		compass.SetActive(false);
	}

	private void Update()
	{
		if (manager.state == State.Trial)
		{
			FlickerControl();
			if (manager.TRIAL < N.trialsBlock) // Training
			{
				if (manager.timeElapsed > Seconds.training) { flicker.SetActive(false); }
			}

			else // Test
			{
				if (manager.timeElapsed > Seconds.movement || hit==1)
				{
					if (!evaluated)
					{
						evaluated = true;

						// Time and Distance
						time = manager.timeElapsed;
						dist = Vector3.Distance(transform.position, target.position);

						if (hit == 1)
						{
							feedback.text = "Good job!";
							score.text = String.Format("Time: {0}", (int)time);
						}
						else
						{
							feedback.text = "You are almost there.";
							score.text = String.Format("Distance to target: {0}", (int)dist);
						}

						compass.SetActive(false);
						flicker.SetActive(false);
						UIFeedback.SetActive(true);
						manager.evaluated[playerID] = true;
					}
				}
				else
				{
					MoveCursor();
				}
			}
		}
	}

	private void FlickerControl()
	{
		if (!flicker.activeSelf) { flicker.SetActive(true); }

		for (int i = 0; i < N.freq; i++)
		{
			v1 = Math.Sign(Math.Sin(2.0f * Math.PI * manager.timeElapsed * Constants.instance.Hz[i]));
			if (v1 == -1) { v1 = 0; }
			mr[i].material.mainTexture = manager.Textures[1 - v1];
		}
	}

	private void MoveCursor()
	{

		xMov = manager.movement[0, playerID];
		zMov = manager.movement[1, playerID];

		transform.Translate(new Vector3(xMov, 0, zMov) * speed * Time.deltaTime);

		dist = Vector3.Distance(transform.position, target.position);
		if (dist < criticalDist) { hit = 1; }
	}

	 
}
