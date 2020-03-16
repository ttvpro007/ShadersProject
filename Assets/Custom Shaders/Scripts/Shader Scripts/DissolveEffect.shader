Shader "Custom/DissolveEffect"
{
    Properties
    {
        _NoiseTex("Albedo (RGB)", 2D) = "white" {}
        _Color1("Color1", Color) = (1,0,0,1)
        _Color2("Color2", Color) = (0,1,0,1)
        alphaTime("Alpha", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Geometry+20"}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha

        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_NoiseTex;
        };

        fixed4 _Color1;
        fixed4 _Color2;
        float alphaTime;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 noise = tex2D (_NoiseTex, IN.uv_NoiseTex);
            //float alphaTime = 1 - frac(_Time * 10);
            if (noise.r < alphaTime * 0.5)
            {
                o.Emission = _Color1;
            }
            else if (noise.r < alphaTime)
            {
                o.Emission = _Color2;
            }
            else
            {
                o.Emission = fixed4(0,0,0,0);
            }
        }
        ENDCG
    }
    FallBack "Diffuse"
}
