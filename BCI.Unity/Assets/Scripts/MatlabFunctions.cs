using UnityEngine;
using System.IO;
using System.Linq;
using System;

public class MatlabFunctions : MonoBehaviour {
	protected System.Random rnd = new System.Random();
	// RandPerm
	private void Awake()
	{
		DateTime localDate = DateTime.Now;
	}
	protected int[] RandPerm(int n, System.Random rnd)
	{
		//Debug.Log("RandPerm");
		var idx = Enumerable.Range(1, n).OrderBy(r => rnd.Next()).ToArray();
		return idx;
	}

	// LinSpace

	protected float[] LinSpace(float d1, float d2, int n)
	{
		int nl = n - 1;

		float[] y = new float[nl + 1];

		for (int i = 0; i <= nl; i++)
		{
			y[i] = d1 + i * (d2 - d1) / nl;
		}

		return y;
	}

	// RandSampleWithoutReplacement

	protected int[] RandSampleWithoutReplacement(int n, int k, System.Random rnd)
	{

		Debug.Log("RandSampleWithoutReplacement");

		int[] tmp; tmp = RandPerm(n, rnd);
		int[] y = new int[k];

		for (int i = 0; i < k; i++)
		{
			y[i] = tmp[i];
		}

		Array.Sort(y);

		return y;
	}

	// PrintRowsAndColsCount

	protected void PrintRowsAndColsCount<T>(T[,] array)
	{
		int rank = array.Rank; // Will always be 2 in this case, since it's a 2D array

		int rows = array.GetUpperBound(0) - array.GetLowerBound(0) + 1;
		int cols = array.GetUpperBound(1) - array.GetLowerBound(1) + 1;

		Debug.Log(rows);
		Debug.Log(cols);
	}


	// WriteTrialInfo

	protected void Write2D(float[,] array, string pathFNAME)
	{
		int nRows = array.GetUpperBound(0) - array.GetLowerBound(0) + 1;
		int nCols = array.GetUpperBound(1) - array.GetLowerBound(1) + 1;
		if (!File.Exists(pathFNAME))
		{
			using (StreamWriter sw = File.CreateText(pathFNAME))
			{
				for (int i = 0; i < nRows; i++)
				{
					string content = "";
					for (int j = 0; j < nCols; j++)
					{
						content += array[i, j].ToString() + ",";
					}
					content = content.Substring(0, content.Length - 1);
					sw.WriteLine(content);
				}
			}
		}

		using (StreamWriter sw = File.AppendText(pathFNAME))
		{
			for (int i = 0; i < nRows; i++)
			{
				string content = "";
				for (int j = 0; j < nCols; j++)
				{
					content += array[i, j].ToString() + ",";
				}
				content = content.Substring(0, content.Length - 1);
				sw.WriteLine(content);
			}
		}
	}


	// Write1D
	protected void Write1D(float[] array, string pathFNAME)
	{
		using (StreamWriter sw = new StreamWriter(pathFNAME, true))
		{
			int nRows = array.GetUpperBound(0) - array.GetLowerBound(0) + 1;
			for (int i = 0; i <= nRows - 1; i++)
			{
				sw.Write(array[i]);
				sw.Write("\t");
			}

			sw.Write("\n");
		}
	}

	protected void Write1D(int[] array, string pathFNAME)
	{
		using (StreamWriter sw = new StreamWriter(pathFNAME, true))
		{
			int nRows = array.GetUpperBound(0) - array.GetLowerBound(0) + 1;
			for (int i = 0; i <= nRows - 1; i++)
			{
				sw.Write(array[i]);
				sw.Write("\t");
			}

			sw.Write("\n");
		}
	}

	protected void Write1D(float value, string pathFNAME)
	{
		using (StreamWriter sw = new StreamWriter(pathFNAME, true))
		{
			sw.Write(value);
			sw.Write("\t");
			sw.Write("\n");
		}
	}

	protected string ReadTXT(string pathFNAME)
	{
		StreamReader sr = new StreamReader(pathFNAME);
		string txt = "";
		while (!sr.EndOfStream)
		{
			txt = sr.ReadLine();
		}
		sr.Close();
		return txt;
	}
	// Sum

	protected int Sum(params int[] x)
	{
		int y = 0;

		for (int i = 0; i < x.Length; i++)
		{
			y += x[i];
		}

		return y;
	}


	// meanl

	protected float Mean(params int[] x)
	{
		int y = Sum(x);
		float result = (float)y / x.Length;
		return result;
	}

	protected int[] Progression(int x0, int xn, int delta = 1)
	{
		int[] y = new int[(xn - x0) / delta + 1];
		for (int i = 0; i < y.Length; i++)
		{
			y[i] = x0 + delta * i;
		}
		return y;
	}

	protected float[] Progression(float x0, float xn, float delta = 1f)
	{
		int L =(int) Math.Floor((xn - x0) / delta) + 1;
		float[] y = new float[L];
		for (int i = 0; i < y.Length; i++)
		{
			y[i] = x0 + delta * i;
		}
		return y;
	}

	protected int[] RepMat1D(int[] M1, int n)
	{
		int L = M1.Length;
		int[] M2 = new int[L * n];
		for (int i = 0; i < M2.Length; i++)
		{
			M2[i] = M1[i % M1.Length];
		}
		return M2;
	}

	protected float[] RepMat1D(float[] M1, int n)
	{
		int L = M1.Length;
		float[] M2 = new float[L * n];
		for (int i = 0; i < M2.Length; i++)
		{
			M2[i] = M1[i % M1.Length];
		}
		return M2;
	}

	protected int[] Shuffle(int[] x)
	{
		int L = x.Length;
		int[] y = new int[L];
		int[] idx1 = RandPerm(L, rnd);

		for (int i = 0; i < L; i++)
		{
			y[i] = x[idx1[i] - 1];
		}
		return y;
	}

	protected int[,] Shuffle(int[,] x)
	{
		int L = x.GetLength(0);
		int D = x.GetLength(1);
		int[,] y = new int[L, D];
		int[] idx1 = RandPerm(L, rnd);

		for (int i = 0; i < L; i++)
		{
			for (int j = 0; j < D; j++)
			{
				y[i, j] = x[idx1[i] - 1, j];
			}

		}
		return y;
	}

	protected bool Any(bool[] input)
	{
		int count = 0;
		foreach (bool x in input)
		{
			if (x == false)
				count++;
		}
		if (count == input.Length) { return false; }
		else { return true; }
	}

	protected bool All(bool[] input)
	{
		int count = 0;
		foreach (bool x in input)
		{
			if (x == true)
				count++;
		}
		if (count == input.Length) { return true; }
		else { return false; }
	}
}
