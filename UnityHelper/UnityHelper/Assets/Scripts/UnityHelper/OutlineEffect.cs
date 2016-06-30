using UnityEngine;
using System.Collections;

public class OutlineEffect : MonoBehaviour {

	//two pixel outline	
//    private int[] outlineX = {2, -2, 0,  0};
//    private int[] outlineY = {0,  0, 2, -2};

	public int xShadowOffset = 2;
	public int yShadowOffset = -2;
//	public Color colorShadow = Color.black;

	public int iOutlineOffset = 2;
	public bool isOutline = false;
	public bool isShadow = true;

	//two pixel drop shadow
//	private int[] outlineX = { -4 };
//    private int[] outlineY = { -4 };
	private int[] outlineX;
	private int[] outlineY;

	private ArrayList childArray;
    private Vector3 tempPosition;

    void Start () {         

		if (isOutline) {
			outlineX = new int[4];
			outlineY = new int[4];

			outlineX[0] = iOutlineOffset;
			outlineY[0] = 0;

			outlineX[1] = -iOutlineOffset;
			outlineY[1] = 0;

			outlineX[2] = 0;
			outlineY[2] = iOutlineOffset;

			outlineX[3] = 0;
			outlineY[3] = -iOutlineOffset;


		} else if (isShadow) {
			outlineX = new int[1];
			outlineY = new int[1];

			outlineX[0] = xShadowOffset;
			outlineY[0] = yShadowOffset;
		} else {
			outlineX = new int[0];
			outlineY = new int[0];

		}



        //make children and arrange them
        //x and z are relative to the parent, but z is absolute
                tempPosition = gameObject.transform.position + new Vector3(0, 0, gameObject.transform.position.z - 0.1f);       
//                tempPosition = gameObject.transform.position;       


        childArray = new ArrayList();
		
        for (int i=0;i<(outlineX.Length);i++) {           
            GameObject child = new GameObject("outlineChild"); 
            child.AddComponent(typeof (GUIText));
            child.transform.parent = gameObject.transform;         
            child.GetComponent<GUIText>().text = gameObject.GetComponent<GUIText>().text;
            child.GetComponent<GUIText>().font = gameObject.GetComponent<GUIText>().font;
            child.GetComponent<GUIText>().fontSize = gameObject.GetComponent<GUIText>().fontSize;
            child.GetComponent<GUIText>().material.color = Color.black;
//            child.GetComponent<GUIText>().material.color = colorShadow;
			child.GetComponent<GUIText>().anchor = gameObject.GetComponent<GUIText>().anchor;
			child.GetComponent<GUIText>().alignment = gameObject.GetComponent<GUIText>().alignment;
            child.transform.position = tempPosition;

            if(i<(outlineX.Length)) {
                child.transform.GetComponent<GUIText>().pixelOffset = new Vector2(outlineX[i],outlineY[i]);


            }

            child.transform.GetComponent<GUIText>().pixelOffset += GetComponent<GUIText>().pixelOffset;         
			
			childArray.Add (child);
			
        }

    }   
	
	void Update() {
		int i;
		for (i = 0; i < childArray.Count; i++) {
			((GameObject) childArray[i]).GetComponent<GUIText>().text = gameObject.GetComponent<GUIText>().text;
			((GameObject) childArray[i]).GetComponent<GUIText>().alignment = gameObject.GetComponent<GUIText>().alignment;
			((GameObject) childArray[i]).GetComponent<GUIText>().lineSpacing = gameObject.GetComponent<GUIText>().lineSpacing;
			((GameObject) childArray[i]).GetComponent<GUIText>().enabled = gameObject.GetComponent<GUIText>().enabled;
		}
		
	}
}
