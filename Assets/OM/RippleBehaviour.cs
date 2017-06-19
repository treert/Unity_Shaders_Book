using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleBehaviour : MonoBehaviour {

    int _width = 100;
    int _height = 100;
    public float _radius = 10;
    int _speed = 2;

    RenderTexture _ripple_tex;
    RenderTexture _ripple_tex_swap;

    public RenderTexture _target_tex;

    Shader _ripple_render_shader;
    Material _render_mat;

    Shader _ripple_shader;
    Material _ripple_mat;

	// Use this for initialization
	void Start () {
        //if(_target_tex == null)
        //{
        //    enabled = false;
        //    return;
        //}

        _width = Screen.width / _speed;
        _height = Screen.height / _speed;

        //_width = _target_tex.width;
        //_height = _target_tex.height;

        _ripple_tex = new RenderTexture(_width, _height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
        _ripple_tex_swap = new RenderTexture(_width, _height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
        _ripple_tex.wrapMode = TextureWrapMode.Clamp;
        _ripple_tex_swap.wrapMode = TextureWrapMode.Clamp;

        _ripple_render_shader = Shader.Find("Ripple/RippleRenderShader");
        _render_mat = new Material(_ripple_render_shader);

        _ripple_shader = Shader.Find("Ripple/RippleShader");
        _ripple_mat = new Material(_ripple_shader);
	}
	
	// Update is called once per frame
	void Update () {
        if(Input.GetMouseButtonDown(0))
        {
            Drop(Input.mousePosition.x, Input.mousePosition.y, _radius * 1.5f, 0.14f);
        }
        else
        {
            Drop(Input.mousePosition.x, Input.mousePosition.y, _radius , 0.01f);
        }
        High();
        CalcOffet();
        //Graphics.Blit(_ripple_tex, _target_tex);
    }

    void OnGUI()
    {
        //Render();
    }

    void OnPostRender()
    {

    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        _render_mat.SetTexture("_RippleTex", _ripple_tex);
        Graphics.Blit(src, dst, _render_mat);
    }

    void Drop(float x, float y, float radius, float strenght)
    {
        Debug.Log(Input.mousePosition);
        _ripple_mat.SetFloat("_DropPosX", x / _speed);
        _ripple_mat.SetFloat("_DropPosY",_height - y / _speed);
        _ripple_mat.SetFloat("_DropRadius", _radius);
        _ripple_mat.SetFloat("_DropStrength", strenght);
        RenderForResult(ref _ripple_tex, 0);
    }

    void High()
    {
        RenderForResult(ref _ripple_tex, 1);
    }

    void CalcOffet()
    {
        RenderForResult(ref _ripple_tex, 2);
    }

    void RenderForResult(ref RenderTexture a, int pass)
    {
        Graphics.Blit(a, _ripple_tex_swap, _ripple_mat, pass);
        var t = a;
        a = _ripple_tex_swap;
        _ripple_tex_swap = t;
    }

    void Render()
    {
        Graphics.Blit(_ripple_tex, _render_mat);
    }
}
