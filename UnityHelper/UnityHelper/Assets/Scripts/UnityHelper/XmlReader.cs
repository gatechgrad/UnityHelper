using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.IO;

public class XmlReader : MonoBehaviour {

	
	public TextAsset CellLayoutXml;
	
	public GameObject PrefabObject01;
	public GameObject PrefabObject02;
	public GameObject PrefabObject03;
	public GameObject PrefabObject04;
	public GameObject PrefabObject05;

	public float fCellSize = 2f;
	public int NUM_COLS = 9;
	public int NUM_ROWS = 9;



	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}


	public void GetLevel() {
		
		TextAsset GameAsset = CellLayoutXml;
		
//		List<TextAsset> allLevels = new List<TextAsset>();
		
//		allLevels.Add(CellLayoutXml);
		
		
//		if (iLevel < allLevels.Count) {
//			GameAsset = allLevels[iLevel];
//		}
		
		XmlDocument xmlDoc = new XmlDocument();
		xmlDoc.LoadXml(GameAsset.text);
		XmlNodeList tilesList = xmlDoc.SelectNodes("/map/layer/data/tile");
			
		Quaternion qRotateX = Quaternion.identity;
		
		
		int i;
		i = 0;
		foreach (XmlNode tile in tilesList) {
			
			int iValue =  int.Parse(tile.Attributes["gid"].Value);
			
			Vector3 vectTemp = new Vector3();
			vectTemp.x = (float) (i % NUM_COLS);
			vectTemp.y = (float) ((NUM_ROWS - 1) - (i / NUM_COLS));
			
			vectTemp *= fCellSize;
			
			switch (iValue) {
			case 1:
				if (PrefabObject01 != null) {
					Instantiate(PrefabObject01, vectTemp, qRotateX);
				}
				break;
			case 2:
				Instantiate(PrefabObject02, vectTemp, qRotateX);
				break;
			case 3:
				Instantiate(PrefabObject03, vectTemp, qRotateX);
				break;
			case 4:
				Instantiate(PrefabObject04, vectTemp, qRotateX);
				break;
			case 5:
				Instantiate(PrefabObject05, vectTemp, qRotateX);
				break;
			}
			
			i++;
			
		}

		
	}

}
