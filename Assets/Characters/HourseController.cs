using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HourseController : MonoBehaviour
{
    public Animator driverAnimator;
    public Animator hourseAnimator;
    // Start is called before the first frame update
    void Start()
    {
        //var runHash = Animator.StringToHash("Run");
        //hourseAnimator.Play(runHash);
        var sitHash = Animator.StringToHash("Sit");
        driverAnimator.Play(sitHash);



    }
    private void OnEnable()
    {
        hourseAnimator.SetBool("run", true);
        //driverAnimator.SetBool("ride", true);
        hourseAnimator.SetTrigger("TriggerRun");
    }
    // Update is called once per frame
    void Update()
    {
        
    }

    public void Ride()
    {

        var sitHash = Animator.StringToHash("Sit");
        driverAnimator.Play(sitHash);
        hourseAnimator.SetBool("run", true);
        //driverAnimator.SetBool("ride", true);
        hourseAnimator.SetTrigger("TriggerRun");
        //driverAnimator.SetTrigger("Triggerride");

    }
}
