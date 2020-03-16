Shader "Post Processing/Laser Scan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[Header(Wave)]
		_WaveDistance ("Distance from Player", Float) = 10
		_WaveTrail ("Length of Trail", Range(0.01, 10)) = 1
		_WaveColor ("Wave Color", Color) = (1, 0, 0, 1)
		_PlayerPos ("Player Position", Vector) = (0, 0, 0, 1)
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
				float3 worldSpaceDirection :TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

			// sampler data
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;

			// scan properties
			float _WaveDistance;
			float _WaveTrail;
			float4 _WaveColor;

			// transformation
			float4x4 _ViewProjectionInverse;
			float3 _PlayerPos;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				float4 W = mul(_ViewProjectionInverse, float4(2 * v.uv.x - 1, 2 * v.uv.y - 1, 0.5, 1));
				W.xyz /= W.w;
				W.xyz -= _WorldSpaceCameraPos;

				float4 W0 = mul(_ViewProjectionInverse, float4(0, 0, 0.5, 1));
				W0.xyz /= W0.w;
				W0.xyz -= _WorldSpaceCameraPos;
				o.worldSpaceDirection = W.xyz / length(W0.xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//// Linear Laser Scan
				//fixed4 col = tex2D(_MainTex, i.uv);
				//fixed depth = tex2D(_CameraDepthTexture, i.uv).r;
				//depth = Linear01Depth(depth) * _ProjectionParams.z;

				//if (depth > _WaveDistance - _WaveTrail && depth < _WaveDistance)
				//{
				//	return lerp(col, _WaveColor, (depth - (_WaveDistance - _WaveTrail)) / _WaveTrail);
				//}

				//return col;

				// World Position Laser Scan
				fixed4 col = tex2D(_MainTex, i.uv);
				float depth = tex2D(_CameraDepthTexture, i.uv).r;
				depth = LinearEyeDepth(depth);
				float3 worldPos = _WorldSpaceCameraPos + i.worldSpaceDirection * depth;
				float distance = length(worldPos - _PlayerPos);

				float timeFactor = pow(frac(_Time.y), 0.5);
				if (distance < _WaveDistance * timeFactor)
				{
					return lerp(_WaveColor, col, pow(timeFactor, 3));
				}

				return col;
            }

            ENDCG
        }
    }
}
