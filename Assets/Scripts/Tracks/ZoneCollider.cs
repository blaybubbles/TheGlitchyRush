using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZoneCollider : MonoBehaviour
{
    public int currentZone = 0;
    public int newZone = 0;
    public bool startGlith = false;
    public bool endGlith = false;
    public bool switchCharacter = false;
    public void SwitchZone()
    {
        if(switchCharacter)
        TrackManager.instance.ChangeCharacter(newZone);
        if (startGlith)
        {
            TrackManager.instance.StartGlitch();
            this.gameObject.SetActive(false);
        }
    }
}
