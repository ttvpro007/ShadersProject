Shader "Unlit/Wave Outline"
{
    Properties
    {
		_MainTex ("Main Texture", 2D) = "white" {}
		_OutineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth ("Outline Width", Range(1f, 5f)) = 1
    }
    SubShader
    {
		Tags { "Queue" = "Transparent" }
		// Grab the screen behind the object into _BackgroundTexture
		
		CGINCLUDE
		
		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct v2f
		{
			float4 position : POSITION;
			float4 color : COLOR;
			float3 normal : NORMAL;
		};

		float4 _OutlineColor;
		float _OutlineWidth;

		v2f vert(appdata IN)
		{
			IN.vertex.xyz *= _OutlineWidth;
		}

		ENDCG
    }
}
