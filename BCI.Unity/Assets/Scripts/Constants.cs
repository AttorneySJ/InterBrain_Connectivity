using System.Collections.Generic;
using System.Runtime.InteropServices;
using System;
using UnityEngine;
using System.IO;

[RequireComponent(typeof(ProcessManager))]
public class Constants : MatlabFunctions
{
    public static Constants instance = null;
    private ProcessManager manager;

    private int[] cond2useB;
    private int[] cond2useT;
    private int[] trialType;
    private int Radius = 15;
    private string outFile;

    public Dictionary<int, Vector3> cuePosition = new Dictionary<int, Vector3>();
    public Dictionary<int, Vector3> targetPosition = new Dictionary<int, Vector3>();
    public float[] Hz;
    public int[] TRIALTYPE;

    private void Awake()
    {
        if (instance == null)
            instance = this;
        else if (instance != this)
            Destroy(gameObject);
        DontDestroyOnLoad(gameObject);

        Hz = new float[4] { 7f/2, 11f/2, 5f/2, 9f/2 };
        GetSession();
        SetupPort();
        BlockStructure();
        SetupDisplay();

        manager = GetComponent<ProcessManager>();
        manager.SetupScene();
    }

    private void GetSession()
    {
		string m_Path = System.IO.Directory.GetCurrentDirectory();
		m_Path = m_Path.Replace("\\", "//");
		m_Path = m_Path.Replace("Unity", "Matlab");
		string session = ReadTXT(m_Path + "//session.txt");
        outFile = m_Path + "//Data//" + session + "//" + session;

        Str.session = session;

        Str.trialMatrixTXT = outFile + ".trialMatrix.csv";
        Str.frameMatrixTXT = outFile + ".frameMatrix.csv";

        if (!File.Exists(Str.trialMatrixTXT))
        {
            using (StreamWriter sw = File.CreateText(Str.trialMatrixTXT))
            {
                string content = "trial,block,taskType,targetLoc,start,end,success1,time1,distance1,success2,time2,distance2";
                sw.WriteLine(content);
            }
        }

        if (!File.Exists(Str.frameMatrixTXT))
        {
            using (StreamWriter sw = File.CreateText(Str.frameMatrixTXT))
            {
                string content = "trial,block,frame,time,trigger,state,sel_x1,sel_y1,x1,y1,success1,sel_x2,sel_y2,x2,y2,success2";
                sw.WriteLine(content);
            }
        }

        //Profiler.logFile = "expLog";
        //Profiler.enableBinaryLog = true;
        //Profiler.enabled = true;

    }

    private void SetupPort()
    {
        for (int i = 0; i < Port.address.Length; i++)
        {
            Port.port[i] = Convert.ToInt32(Port.address[i], 16);
        }
    }

    private void BlockStructure()
    {
        switch (Options.train)
        {
            case 1:
                cond2useB = new int[2] { 1, 5 };
                cond2useT = new int[2] { 11, 15 };
                break;
            case 2:
                cond2useB = new int[2] { 3, 7 };
                cond2useT = new int[2] { 13, 17 };
                break;
            case 3:
                cond2useB = new int[4] { 1, 5, 3, 7 };
                cond2useT = new int[8] { 12, 14, 16, 18, 22, 24, 26, 28 };
                break;
        }

        N.trialsBlock = N.repetitions * cond2useB.Length;
        N.trialsTotal = N.trialsBlock * N.blocks;

        TRIALTYPE = new int[N.trialsTotal];

        for (int i = 0; i < N.blocks; i++)

        {

            if (i == 0) // baseline
            {
                trialType = RepMat1D(cond2useB, N.repetitions);
            }

            else // test
            {
                trialType = RepMat1D(cond2useT, N.repetitions / N.players);
            }

            trialType = Shuffle(trialType);

            for (int j = 0; j < N.trialsBlock; j++)
            {
                TRIALTYPE[(i * N.trialsBlock) + j] = trialType[j];
            }
        }
    }

    private void SetupDisplay()
    {
        for (int i = 0; i < Str.cuePosition.Length; i++)
        {
            Vector3 cuePos = Quaternion.AngleAxis(i * -90, Vector3.up) * Vector3.right * Radius;
            cuePos = cuePos + new Vector3(0, 0.2f, 0);
            cuePosition.Add(i * 2 + 1, cuePos);
        }

        for (int i = 0; i < Str.targetPosition.Length; i++)
        {
            Vector3 targetPos = Quaternion.AngleAxis(i * -45, Vector3.up) * Vector3.right * Radius * 2;
            targetPos = targetPos + new Vector3(0, 0.2f, 0);
            targetPosition.Add(i + 1, targetPos);
        }
    }
}

public class Options
{
    public static bool recordEEG = true;
    public static int train = 3;
}


public class N
{
    public static int players = 2;
    public static int freq = 4;
    public static int blocks = 11;
    public static int trialsBlock;
    public static int trialsTotal;
    public static int repetitions = 4;
}

public class Seconds
{
    public static float blockRest = 5f;
    public static float trialRest = 1f;
    public static float training = 20f;
    public static float movement = 20f;
    public static float feedback = 1f;
    public static float trigger = .1f;
}

public class Str
{
    public static string[] players = new string[] { "P1", "P2" };
    public static string[] trial = new string[] { "right", "up", "left", "down", "free" };
    public static string[] cuePosition = new string[] { "right", "up", "left", "down" };
    public static string[] targetPosition = new string[] { "E", "NE", "N", "NW", "W", "SW", "S", "SE" };
    public static string[] train = new string[] { "left.right", "up.down", "left.right.up.down" };
    public static string[] blockType = new string[] { "train", "test" };
    public static string[] taskType = new string[] { "solo", "joint" };
    public static string trialMatrixTXT;
    public static string frameMatrixTXT;
    public static string session;

}

public class Trig
{

    public static List<int> trial = new List<int> { 1, 3, 5, 7, 11, 12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 25, 26, 27, 28 };

    public static int restTrial = 99;

    public static int initAnalysis = 252;
    public static int stopAnalysis = 253;

    public static int startRecording = 254;
    public static int stopRecording = 255;

}

public class Port
{
    public static string[] address = new string[2] { "2FF8", "21" };
    public static int[] port = new int[2];
}


public class PortAccess
{
    [DllImport(dllName: "inpoutx64.dll", EntryPoint = "Out32")]
    public static extern void Output(int address, int value);

    [DllImport(dllName: "inpoutx64.dll", EntryPoint = "Inp32")]
    public static extern char Input(int address);
}

public enum State { BlockRest = 0, Inactive = 1, TrialRest = 2, Trial = 3, Feedback = 4 };
public enum FrameData { trial = 0, block = 1, frame = 2, time = 3, trigger = 4, state = 5, sel_x1 = 6, sel_y1 = 7, x1 = 8, y1 = 9, success1 = 10, sel_x2 = 11, sel_y2 = 12,x2 = 13, y2 = 14, success2 = 15 };
public enum TrialData { trial = 0, block = 1, taskType = 2, targetLoc = 3, start = 4, end = 5, success1 = 6, time1 = 7, distance1 = 8, success2 = 9, time2 = 10, distance2 = 11 };
