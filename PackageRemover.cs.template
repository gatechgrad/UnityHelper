//2019 Levi D. Smith
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;

public static class PackageRemover {
    static RemoveRequest myRequest;
    static Queue<string> myQueue;

    [MenuItem("Build/Package Remover")]
    public static void RemovePackages() {
        Debug.Log("Remove Packages");
        string strPackage;

        myQueue = new Queue<string>();

        strPackage = "com.unity.textmeshpro";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.ads";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.analytics";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.purchasing";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.collab-proxy";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.multiplayer-hlapi";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.timeline";
        myQueue.Enqueue(strPackage);

        strPackage = "com.unity.xr.legacyinputhelpers";
        myQueue.Enqueue(strPackage);

                

        EditorApplication.update += Progress;
        EditorApplication.LockReloadAssemblies();

        string strNextReq = myQueue.Dequeue();
        Debug.Log("Removing: " + strNextReq);        
        myRequest = Client.Remove(strNextReq);

        
    }

    static void Progress() {
        if (myRequest.IsCompleted) {
            if (myRequest.Status == StatusCode.Success) {
                Debug.Log("Removed: " + myRequest.PackageIdOrName);
            } else if (myRequest.Status >= StatusCode.Failure) {
                Debug.Log(myRequest.Error.message);
            }

            if (myQueue.Count > 0) {
                string strNextReq = myQueue.Dequeue();
                Debug.Log("Removing: " + strNextReq);
                myRequest = Client.Remove(strNextReq);
            } else {
                EditorApplication.update -= Progress;
                EditorApplication.UnlockReloadAssemblies();
            }

            


        }
    }
}