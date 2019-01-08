using System;
using UnityEngine;
using RealtimeBuffer;
using UnityEngine.UI;

public class ProcessManager : MatlabFunctions
{
	[Header("Trial Count")]
	public int TRIAL;
	private int trial;
	public int BLOCK;
    public State state;

	[Header("Cues")]
	[SerializeField] private int trigger = 0;
	[SerializeField] private GameObject trainingCue;
	[SerializeField] private Vector3 cuePos;
	[SerializeField] private GameObject target;
	[SerializeField] private Vector3 targetPos;
	public int taskType;
	private int trialTrig;
	private int targetLoc;

	[Header("UI")]
	[SerializeField] private GameObject UIEnd;
	[SerializeField] private Text[] EndText;

	[Header("Players")]
	[SerializeField] private Player[] players;
	public bool[] evaluated;
	public float[,] movement = new float[2, N.players];


	[Header("Buffer")]
	[SerializeField] private string host = "127.0.0.1";
	[SerializeField] private int port = 9999;
	[SerializeField] private bool bufferConnected = false;

	private UnityBuffer socket = new UnityBuffer();
	private Header hdr;
	private int nSample;
	private int lastSample;

	// Timing
	public float timeElapsed = 0;
	private float startTime = 0;
	private float T0 = 0;
	private int FRAME;

	// Resources
	public Texture2D[] Textures = new Texture2D[2];
	public Sprite[] CursorCol = new Sprite[2];

	//Data Entry
	private float[,] frameData = new float[1, 16];
	private float[,] trialData = new float[1, 12];


	private void Awake()
	{
		// Patterns
		Textures[0] = Resources.Load("pattern.a") as Texture2D;
		Textures[1] = Resources.Load("pattern.b") as Texture2D;
		
		TRIAL = 0;
		lastSample = -1;
        movement = new float[2, 2] { { 0, 0 }, { 0, 0 } };
        taskType = -1;
    }
	public void SetupScene()
	{
		players = FindObjectsOfType<Player>();
		foreach (Player player in players) { player.enabled = false; }
		UIEnd.SetActive(false);
		trainingCue.SetActive(false);
		target.SetActive(false);

		evaluated = new bool[N.players];
		for (int i = 0; i < N.players; i++) { evaluated[i] = false; }
	}

	private void Start()
	{
		if (Options.recordEEG)
		{
			PortAccess.Output(Port.port[0], Trig.startRecording);
			Debug.Log("sending ready signal to amplifiers...");
		}
		
		if (!socket.isConnected())
		{
			socket.connect(host, port);
			Debug.Log("Connecting to " + host + ":" + port);
		}

		if (socket.isConnected())
		{
			Debug.Log("Connected.");
			hdr = socket.getHeader();
			bufferConnected = true;
		}
		FRAME = 0;
		TRIAL = 0;
		BLOCK = 0;
		trial = 0;
        state = State.BlockRest;
    }

	private void Update()
	{
        // Write Frame Data
        frameData = new float[1, 16];
		FRAME++;
		frameData[0, (int)FrameData.trial] = TRIAL + 1;
		frameData[0, (int)FrameData.block] = BLOCK + 1;
		frameData[0, (int)FrameData.frame] = FRAME;
        
        if (TRIAL == N.trialsTotal) { QuitGame(); }

		trigger = PortAccess.Input(Port.port[0]);
		timeElapsed = Time.time - startTime;

		switch (state)
		{
			case State.Inactive:
				if (!Options.recordEEG) { StartNewTrial(); }
				else if (trigger == 0) { StartNewTrial(); }
				break;

			case State.BlockRest:
				if (!UIEnd.activeSelf)
				{
					if (BLOCK != 0)
					{
						foreach (Text tt in EndText)
						{
							tt.text = "Please sit still and wait for the next block.";
						}
					}
					else
					{
						foreach (Text tt in EndText)
						{
							tt.text = "Please sit still and wait for the start of the experiment.";
						}
					}
					
					UIEnd.SetActive(true);
					startTime = Time.time;
				}

				if (BLOCK == 0 || timeElapsed > Seconds.blockRest)
				{
					if (BLOCK != 0)
					{
						foreach (Text tt in EndText)
						{
							tt.text = "BLOCK " + BLOCK.ToString() + " of " + (N.blocks-1).ToString() + " blocks";
						}
					}

					if (Input.GetKeyUp(KeyCode.Space))
					{
						UIEnd.SetActive(false);
						state = State.Inactive;
						PortAccess.Output(Port.port[0], Trig.initAnalysis);
					}
				}				        
				break;

			case State.TrialRest:
				RunTrialRest();
				break;

			case State.Trial:
				RunTrial();
				break;

			case State.Feedback:
				if (timeElapsed > Seconds.feedback)
					EndTrial();
				break;
		}

        frameData[0, (int)FrameData.time] = Time.time;
        frameData[0, (int)FrameData.trigger] = PortAccess.Input(Port.port[0]);
        frameData[0, (int)FrameData.state] = (int)state;
        for (int i = 0; i < N.players; i++)
        {
            frameData[0, i * 5 + 6] = movement[0, i];
            frameData[0, i * 5 + 7] = movement[1, i];
            frameData[0, i * 5 + 8] = players[i].transform.position.x;
            frameData[0, i * 5 + 9] = players[i].transform.position.z;
            frameData[0, i * 5 + 10] = players[i].hit;
        }
        Write2D(frameData, Str.frameMatrixTXT);
    }

	private void StartNewTrial()
	{
		trialData = new float[1, 12];

        
        trialTrig = Constants.instance.TRIALTYPE[TRIAL];

		if (TRIAL < N.trialsBlock) // Training
		{
            targetLoc = trialTrig;
            cuePos = Constants.instance.cuePosition[trialTrig];
			trainingCue.transform.position = cuePos;
			trainingCue.SetActive(true);
		}
		else // Test
		{
            // Reset movement data
            movement = new float[2, 2] { { 0, 0 }, { 0, 0 } };
            lastSample = -1;

            targetLoc = trialTrig % 10;
			targetPos = Constants.instance.targetPosition[targetLoc];
			taskType = (int)Math.Floor((double)trialTrig / 10) - 1;
			target.transform.position = targetPos;
			target.SetActive(true);
		}

		foreach (Player player in players) { player.enabled = true; }
		state = State.TrialRest;
		startTime = Time.time;
		T0 = Time.time;
	}

	private void RunTrialRest()
	{
		if (timeElapsed < Seconds.trigger)
			PortAccess.Output(Port.port[0], Trig.restTrial);

		if (timeElapsed > Seconds.trialRest)
		{
			state = State.Trial;
			startTime = Time.time;
		}
	}

	private void RunTrial()
	{

		if (timeElapsed < Seconds.trigger)
			PortAccess.Output(Port.port[0], trialTrig);

		if (TRIAL < N.trialsBlock)
		{
			if (timeElapsed > Seconds.training)
			{
				trainingCue.SetActive(false);
				EndTrial();
				PortAccess.Output(Port.port[0], Trig.stopAnalysis);
			}
		}
		else
		{
			if (All(evaluated))
			{
                for (int i = 0; i < N.players; i++) { evaluated[i] = false; }
				target.SetActive(false);
				state = State.Feedback;
				startTime = Time.time;
				PortAccess.Output(Port.port[0], Trig.stopAnalysis);
			}
			else if (socket != null && bufferConnected)
			{
				hdr = socket.getHeader();
				nSample = hdr.nSamples;

				if (lastSample < 0) { lastSample = nSample; }
                if (lastSample != nSample)
                {
                    movement = socket.getFloatData(nSample - 2, nSample - 1);
                    lastSample = nSample;
                }
 
			}
		}	
	}

	private void EndTrial()
	{
		foreach (Player player in players) { player.enabled = false; }
		
		// Write Trial Data
		trialData[0, (int)TrialData.trial] = TRIAL + 1;
		trialData[0, (int)TrialData.block] = BLOCK + 1;
		trialData[0, (int)TrialData.taskType] = taskType + 1;
		trialData[0, (int)TrialData.targetLoc] = targetLoc;
		trialData[0, (int)TrialData.start] = T0;
		trialData[0, (int)TrialData.end] = Time.time;

		for (int i = 0; i < N.players; i++)
		{
			trialData[0, i * 3 + 6] = players[i].hit;
			trialData[0, i * 3 + 7] = players[i].time;
			trialData[0, i * 3 + 8] = players[i].dist;
		}

		Write2D(trialData, Str.trialMatrixTXT);
		

		TRIAL = TRIAL + 1;
        trial = TRIAL % N.trialsBlock;
        BLOCK = (TRIAL - trial) / N.trialsBlock;
        if (TRIAL % N.trialsBlock == 0)
		{
			state = State.BlockRest;
			startTime = Time.time;
		}
		else { state = State.Inactive; }
	}

	


	private void QuitGame()
	{
		PortAccess.Output(Port.port[0], Trig.initAnalysis);
		if (bufferConnected)
		{
			socket.disconnect();
			bufferConnected = false;
		}

#if UNITY_EDITOR
		// Application.Quit() does not work in the editor so
		// UnityEditor.EditorApplication.isPlaying need to be set to false to end the game
		UnityEditor.EditorApplication.isPlaying = false;
#else
			Application.Quit();
#endif
	}

}
