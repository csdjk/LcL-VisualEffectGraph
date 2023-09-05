Shader "LcL/VFX/DisableZWriteTUT"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            ZWrite Off
        }
    }
}
