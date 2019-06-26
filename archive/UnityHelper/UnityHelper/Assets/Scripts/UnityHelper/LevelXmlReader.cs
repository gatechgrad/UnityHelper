using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.IO;

public class LevelXmlReader : MonoBehaviour {

	public TextAsset GameAssetLevel01;

	public GameObject PrefabHero;

	public GameObject PrefabFloor;
	public GameObject PrefabBlock00;
	public GameObject PrefabBlock01;
	public GameObject PrefabBlock02;
	public GameObject PrefabBlock03;

	public GameObject PrefabPipe00;
	public GameObject PrefabPipe01;

	public GameObject PrefabEnemy00;
	public GameObject PrefabEnemy01;

	public GameObject PrefabEnemyWall;

	const float TILE_SIZE = 2f;
	const int NUM_COLS = 200;
	const int NUM_ROWS = 14;

	void Start () {
	
	}

	public void GetLevel(int iLevel) {

		TextAsset GameAsset = GameAssetLevel01;

		List<TextAsset> allLevels = new List<TextAsset>();

		allLevels.Add(GameAssetLevel01);


		if (iLevel < allLevels.Count) {
			GameAsset = allLevels[iLevel];
		}

		XmlDocument xmlDoc = new XmlDocument();
		xmlDoc.LoadXml(GameAsset.text);
		XmlNodeList tilesList = xmlDoc.SelectNodes("/map/layer[@name='Environment']/data/tile");
		XmlNodeList charactersList = xmlDoc.SelectNodes("/map/layer[@name='Characters']/data/tile");
//		XmlNodeList enemiesList = xmlDoc.SelectNodes("/map/objectgroup[@name='Enemies']/object");



		Quaternion qRotateX = Quaternion.identity;


		int i;
		i = 0;
		foreach (XmlNode tile in tilesList) {

			int iValue =  int.Parse(tile.Attributes["gid"].Value);

			Vector3 vectTemp = new Vector3();
			vectTemp.x = (float) (i % NUM_COLS);
			vectTemp.y = (float) ((NUM_ROWS - 1) - (i / NUM_COLS));

			vectTemp *= TILE_SIZE;

			switch (iValue) {
			case 1:
				Instantiate(PrefabBlock00, vectTemp, qRotateX);
				break;
			case 3:
				Instantiate(PrefabBlock01, vectTemp, qRotateX);
				break;
			case 4:
				Instantiate(PrefabBlock02, vectTemp, qRotateX);
				break;
			case 5:
				Instantiate(PrefabBlock03, vectTemp, qRotateX);
				break;
			case 9:
				Instantiate(PrefabPipe00, vectTemp, qRotateX);
				break;
			case 17:
				Instantiate(PrefabPipe01, vectTemp, qRotateX);
				break;
			}

			i++;

		}


		i = 0;
		foreach (XmlNode tile in charactersList) {
			
			int iValue =  int.Parse(tile.Attributes["gid"].Value);

			float fRotate = 0f;
			GameObject obj;


			Vector3 vectTemp = new Vector3();
			vectTemp.x = (float) (i % NUM_COLS);
			vectTemp.y = (float) ( (NUM_ROWS - 1) - (i / NUM_COLS));

			vectTemp *= TILE_SIZE;

			switch (iValue) {
			case 2:
				PrefabHero.transform.position = vectTemp;
				break;
			case 6:
				Instantiate(PrefabEnemy00, vectTemp, qRotateX);
				break;
			case 7:
				Instantiate(PrefabEnemy01, vectTemp, qRotateX);
				break;
			case 8:
				Instantiate(PrefabEnemyWall, vectTemp, qRotateX);
				break;
			}
			
			i++;
			
		}


	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
