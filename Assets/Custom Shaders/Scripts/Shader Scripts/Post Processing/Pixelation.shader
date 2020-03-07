Shader "Post Processing/Pixelation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MousePos ("Mouse Position", Vector) = (0, 0, 0, 0)
		_Radius ("Radius", Vector) = (0, 0, 0, 0)
		_Strength ("Strength", Float) = 100
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
			float4 _MousePos;
			float4 _Radius;
			float _Strength;

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
				// Pixelation
				float4 col;
				float dist = distance(i.uv.xy, _MousePos.xy);
				if (dist < _Radius.x && dist < _Radius.y)
				{
					col = tex2D(_MainTex, float2(floor(i.uv.x * _Strength) / _Strength, floor(i.uv.y * _Strength) / _Strength));
				}
				else
				{
					col = tex2D(_MainTex, i.uv);
				}

				return col;
            }

            ENDCG
        }
    }
}
