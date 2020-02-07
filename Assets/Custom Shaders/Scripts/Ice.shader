Shader "Unlit/Ice"
{
    Properties
    {
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_Band("Band", Range(1, 256)) = 1
		_RampPow("Ramp Power", Range(0, 5)) = 0
		_NoiseScale("Noise Scale", Float) = 1
		_Amplitude("Amplitude", Float) = 0
		_Frequency("Frequency", Float) = 0
		_PhaseMultiplier("Phase Multiplier", Float) = 0
        _IceColor ("Ice Color", Color) = (0, 1, 1, 0)
    }
    SubShader
    {
		Tags { "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		// Grab the screen behind the object into _BackgroundTexture
		GrabPass
		{
			"_BackgroundTexture"
		}
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
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 grabPos : TEXCOORD3;
            };

			sampler2D _BackgroundTexture;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
			float _Band;
			float _RampPow;
			float _NoiseScale;
			float _Amplitude;
			float _Frequency;
			float _PhaseMultiplier;
			float4 _IceColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				float4 normal4 = float4(v.normal, 0.0);
				o.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				float4 noise = tex2Dlod(_NoiseTex, float4(o.uv.xy, 0, 0) / _NoiseScale);
				o.vertex.y += (1 + 0.5 * cos(noise.x * _PhaseMultiplier + _Frequency)) * _Amplitude;
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				float3 bump = tex2D(_NoiseTex, i.uv / _NoiseScale).rgb + i.normal.xyz;
				bump = normalize(bump);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float ramp = clamp(dot(bump, lightDir), 0.001, 1.0);
				ramp = 1 - ramp;
				ramp = pow(ramp, _RampPow);
				ramp = ceil(ramp * _Band) / _Band;
				fixed4 lighting = _IceColor * ramp;

				fixed4 noise = tex2D(_NoiseTex, i.uv / _NoiseScale);
				// cos || sin (noise.x || noise.y * phase multiplier + frequency) * amplitude
				i.grabPos.x += sin(noise.x * _PhaseMultiplier + _Time * _Frequency) * _Amplitude;
				i.grabPos.y += cos(noise.y * _PhaseMultiplier + _Time * _Frequency) * _Amplitude;
				fixed4 bgCol = tex2Dproj(_BackgroundTexture, i.grabPos);
                //return lighting;
                return lighting + bgCol;
            }
            ENDCG
        }
    }
}
