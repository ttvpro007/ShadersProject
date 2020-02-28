Shader "Custom/XRAY"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Geometry+10" }
            
            ZWrite Off
            ZTest Always

            Blend SrcAlpha OneMinusSrcAlpha

            Stencil
            {
                Ref 4
                Comp always
                Pass replace
                ZFail keep
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return float4(0, 1, 0, 0.5);
            }
            ENDCG
        }

        Pass
        {
            ZWrite On
            ZTest LEqual
        }
       
        Stencil
        {
            Ref 3
            Comp Less
            Fail keep
            Pass replace
        }

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
            
        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
