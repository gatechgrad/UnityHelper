using UnityEngine;
using System.Collections;

public class OutlineEffectSmall : MonoBehaviour {


	//two pixel drop shadow
	private int[] outlineX = {-2};
    private int[] outlineY = {-2};

	private ArrayList childArray;
    private Vector3 tempPosition;

    void Start () {         
        //make children and arrange them

        tempPosition = gameObject.transform.position + new Vector3(0, 0, -1);       
		
		childArray = new ArrayList();
		
        for (int i=0;i<(outlineX.Length);i++) {           
            GameObject child = new GameObject("outlineChild"); 
            child.AddComponent(typeof (GUIText));
            child.transform.parent = gameObject.transform;         
            child.guiText.text = gameObject.guiText.text;
            child.guiText.font = gameObject.guiText.font;
            child.guiText.fontSize = gameObject.guiText.fontSize;
            child.guiText.material.color = Color.black;
			child.guiText.anchor = gameObject.guiText.anchor;
			child.guiText.alignment = gameObject.guiText.alignment;
            child.transform.position = tempPosition;

            if(i<(outlineX.Length)) {
                child.transform.guiText.pixelOffset = new Vector2(outlineX[i],outlineY[i]);


            }

            child.transform.guiText.pixelOffset += guiText.pixelOffset;         
			
			childArray.Add (child);
			
        }

    }   
	
	void Update() {
		int i;
		for (i = 0; i < childArray.Count; i++) {
			((GameObject) childArray[i]).guiText.text = gameObject.guiText.text;
			((GameObject) childArray[i]).guiText.alignment = gameObject.guiText.alignment;
			((GameObject) childArray[i]).guiText.lineSpacing = gameObject.guiText.lineSpacing;
			((GameObject) childArray[i]).guiText.enabled = gameObject.guiText.enabled;
		}
		
	}
}
