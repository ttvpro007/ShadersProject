﻿Shader "Post Processing/Sin City"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// Sin City FX
				fixed4 col = tex2D(_MainTex, i.uv);
				float grey = (col.r + col.g + col.b) / 3.0f;
				
				if (col.r > 0.5f && col.g < 0.2f && col.b < 0.2f)
				{
					return float4(col.r, 0, 0, 1);
				}

				return float4(grey, grey, grey, 1);
            }

            ENDCG
        }
    }
}
