using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class AnalogProcessGlitch : MonoBehaviour
{

    [SerializeField]
    public Material splitmaterial;

    [SerializeField, Range(0, 5)]
    float splitAmplitude = 0;

    [SerializeField, Range(0, 1)]
    float splitSpees = 0;

    public bool splitOn = false;

    //[SerializeField]
    //public Material material;

    //[SerializeField, Range(0, 1)]
    //float _scanLineJitter = 0;

    //// Vertical jump
    //[SerializeField, Range(0, 1)]
    //float _verticalJump = 0;

    //// Horizontal shake
    //[SerializeField, Range(0, 1)]
    //float _horizontalShake = 0;

    //// Color drift
    //[SerializeField, Range(0, 1)]
    //float _colorDrift = 0;

    //float _verticalJumpTime;

    public UniversalRenderPipelineAsset pipelineAsset;
    public ForwardRendererData forwardRenderer;
    private ScriptableRendererFeature glitchfeature;

    // Start is called before the first frame update
    void Start()
    {
        UpdatePipeline();
    }

    // Update is called once per frame
    void Update()
    {

        //if (splitOn)
        //{
        //    splitmaterial.SetFloat("_Amplitude", splitAmplitude);
        //    splitmaterial.SetFloat("_Speed", splitSpees);
        //    splitmaterial.EnableKeyword("RGB_SPLIT_ON");
        //    glitchfeature?.SetActive(true);

        //}
        //else
        //{
        //    splitmaterial.DisableKeyword("RGB_SPLIT_ON");
        //    glitchfeature?.SetActive(false);
        //}


        //splitmaterial.SetFloat("_Raw", splitOn ? 1.0f : 0.0f);
        //_verticalJumpTime += Time.deltaTime * _verticalJump * 11.3f;

        //var sl_thresh = Mathf.Clamp01(1.0f - _scanLineJitter * 1.2f);
        //var sl_disp = 0.002f + Mathf.Pow(_scanLineJitter, 3) * 0.05f;
        //material.SetVector("_ScanLineJitter", new Vector2(sl_disp, sl_thresh));

        //var vj = new Vector2(_verticalJump, _verticalJumpTime);
        //material.SetVector("_VerticalJump", vj);

        //material.SetFloat("_HorizontalShake", _horizontalShake * 0.2f);

        //var cd = new Vector2(_colorDrift * 0.04f, Time.time * 606.11f);
        //material.SetVector("_ColorDrift", cd);
    }
    public void toggle()
    {
        Debug.Log("GlitchSplitBlit toggle");
        splitOn = !splitOn;
        UpdateFeature();
    }

    public void Off()
    {
        Debug.Log("GlitchSplitBlit off");
        splitOn = false;
        UpdateFeature();
    }

    public void On()
    {
        Debug.Log("GlitchSplitBlit off");
        splitOn = true;
        UpdateFeature();
    }

    private void UpdateFeature()
    {
        if (splitOn)
        {
            splitmaterial.SetFloat("_Amplitude", splitAmplitude);
            splitmaterial.SetFloat("_Speed", splitSpees);
            Debug.Log("splitmaterial != null " + splitmaterial == null);
            Debug.Log("glitchfeature != null " + glitchfeature == null);
            splitmaterial.EnableKeyword("RGB_SPLIT_ON");
            glitchfeature?.SetActive(true);

        }
        else
        {
            splitmaterial.DisableKeyword("RGB_SPLIT_ON");
            glitchfeature?.SetActive(false);
        }
    }

    void UpdatePipeline()
    {
        if (pipelineAsset)
        {
            //pipelineAsset.
            //GraphicsSettings.renderPipelineAsset = pipelineAsset;
            forwardRenderer.rendererFeatures.ForEach(x => Debug.Log("f " + x.name + " " + x.isActive));

            glitchfeature = forwardRenderer.rendererFeatures.Find(x => x.name == "GlitchSplitBlit");
            if (glitchfeature != null)
            {

                Debug.Log("GlitchSplitBlit found");
            }
            else
            {
            }

        }
    }

    private void OnDestroy()
    {
        if (glitchfeature != null && splitmaterial != null)
            Off();
    }
}
