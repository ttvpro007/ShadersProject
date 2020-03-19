Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_OutlineTex ("Outline Texture", 2D) = "white" {}
        _OutlineWidth ("Outline Width", Range(0, 1)) = 1
		_OutlineAmplitude("Outline Amplitude", Float) = 1
		_OutlineFrequency("Outline Frequency", Float) = 1
		_OutlinePhaseMultiplier ("Outline Phase Multifplier", Float) = 1


		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseScale("Noise Scale", Float) = 50
		_Amplitude("Amplitude", Float) = 0.1
		_Frequency("Frequency", Float) = 200
		_PhaseMultiplier("Phase Multiplier", Float) = 30
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+10"}
		
        Pass
        {
            Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			
			sampler2D _OutlineTex;
			float4 _OutlineTex_ST;
            float _OutlineWidth;
			float _OutlineAmplitude;
			float _OutlineFrequency;
			float _OutlinePhaseMultiplier;
			
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			float _NoiseScale;
			float _Amplitude;
			float _Frequency;
			float _PhaseMultiplier;

			float rand(float3 co)
			{
				return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
			}

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
				o.uv = v.uv;
				
				v.vertex.xyz += v.normal * _OutlineWidth * 
					sin(v.uv.x * _OutlinePhaseMultiplier + _Time * _OutlineFrequency) * 
					cos(v.uv.y * _OutlinePhaseMultiplier + _Time * _OutlineFrequency) * 
					rand(v.vertex.xyz) * _OutlineAmplitude;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 noise = tex2D(_NoiseTex, i.uv / _NoiseScale);
				i.uv.x += sin(noise.x * _PhaseMultiplier + _Time * _Frequency) * _Amplitude;
				i.uv.y += cos(noise.y * _PhaseMultiplier + _Time * _Frequency) * _Amplitude;
                return tex2D(_OutlineTex, i.uv);
            }
            ENDCG
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
                float2 uv : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
