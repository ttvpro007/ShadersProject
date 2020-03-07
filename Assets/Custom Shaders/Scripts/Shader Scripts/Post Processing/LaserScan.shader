Shader "Post Processing/Laser Scan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[Header(Wave)]
		_WaveDistance ("Distance From Player", Float) = 10
		_WaveTrail ("Wave Length", Range(0.01, 10)) = 1
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
			float _WaveDistance;
			float _WaveTrail;
			float4 _WaveColor;
			float4x4 _InverseViewMatrix;
			float4x4 _InverseProjectionMatrix;
			float4 _PlayerPos;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
				fixed depth = tex2D(_CameraDepthTexture, i.uv).r;
				depth = Linear01Depth(depth) * _ProjectionParams.z;
				float4 screenPos = float4(2 * (i.uv - float2(0.5f, 0.5f)), depth, 1);
				float4 viewPos = mul(_InverseProjectionMatrix, screenPos);
				float4 worldPos = mul(_InverseViewMatrix, viewPos);
				float dist = distance(worldPos.xyz, _PlayerPos.xyz);

				if (dist < _WaveDistance)
				{
					return _WaveColor;
				}

				return col;
            }

            ENDCG
        }
    }
}
