Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_OutlineTex ("Outline Texture", 2D) = "white" {}
        _OutlineWidth ("Outline Width", Range(0, 1)) = 1

		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseScale("Noise Scale", Float) = 1
		_Amplitude("Amplitude", Float) = 0
		_Frequency("Frequency", Float) = 0
		_PhaseMultiplier("Phase Multiplier", Float) = 0
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
            float _OutlineWidth;
			
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _NoiseScale;
			float _Amplitude;
			float _Frequency;
			float _PhaseMultiplier;

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
				//v.vertex.xyz += v.normal * _OutlineWidth;
				v.vertex.x += v.normal * _OutlineWidth * 2 * sin(v.uv.y * 10000 + _Time * 10);
				v.vertex.y += v.normal * _OutlineWidth * 2 * cos(v.uv.y * 10000 + _Time * 10);
				v.vertex.z += v.normal * _OutlineWidth;
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
