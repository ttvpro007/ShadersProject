Shader "Unlit/Wave"
{
    Properties
    {
        _NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseScale ("Noise Scale", Float) = 1
		_BillboardScale ("Billboard Scale", Float) = 1
		_Amplitude ("Amplitude", Float) = 0
		_Frequency ("Frequency", Float) = 0
		_PhaseMultiplier ("Phase Multiplier", Float) = 0
    }
    SubShader
    {
		Tags { "Queue" = "Transparent" }
        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }
        Pass
        {
			ZTest Always
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
                float4 vertex : SV_POSITION;
                float4 grabPos : TEXCOORD1;
            };

            sampler2D _NoiseTex;
            sampler2D _BackgroundTexture;
            float4 _NoiseTex_ST;
			float _NoiseScale;
			float _BillboardScale;
			float _Amplitude;
			float _Frequency;
			float _PhaseMultiplier;
            
			v2f vert (appdata v)
            {
                v2f o;
                float4 viewSpaceOrigin = mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1));
				float4 viewSpaceVertexPos = float4(v.vertex.x, v.vertex.z, v.vertex.y, 0) * _BillboardScale + float4(0, 0, 3, 0) + viewSpaceOrigin;
                o.vertex = mul(UNITY_MATRIX_P, viewSpaceVertexPos);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
				fixed4 noise = tex2D(_NoiseTex, i.uv / _NoiseScale);
				float dX = i.uv.x - 0.5;
				float dY = i.uv.y - 0.5;
				float r = sqrt(dX * dX + dY * dY);
				r = r > 0.5 ? 0.5 : r;
				float rAlpha = 1 - r / 0.5;
				// cos || sin (noise.x || noise.y * phase multiplier + frequency) * amplitude
				i.grabPos.x += sin(noise.x * _PhaseMultiplier + _Time * _Frequency) * _Amplitude * rAlpha;
				i.grabPos.y += cos(noise.y * _PhaseMultiplier + _Time * _Frequency) * _Amplitude * rAlpha;
                fixed4 col = tex2Dproj(_BackgroundTexture, i.grabPos);
                return col;
            }
            ENDCG
        }
    }
}
