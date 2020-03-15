Shader "Custom/StencilHole"
{
    Properties
    {
        _StencilRef("Stencil Ref", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _CompareFunc("Compare Function", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp("Stencil Operation", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Geometry+1" }

        Pass
        {
            ColorMask 0
            ZWrite Off
            Stencil
            {
                Ref[_StencilRef]
                Comp[_CompareFunc]
                Pass[_StencilOp]
            }
        }
    }
    FallBack "Diffuse"
}
