Shader "Unlit/Display3DComputedParticle"
{
    Properties
    {
		_Color1 ("Color Begin", Color) = (1, 0, 0, 1)
		_Color2 ("Color End", Color) = (0, 1, 0, 1)
    }
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct Particle3D
			{
				float posX;
				float posY;
				float posZ;
				float velX;
				float velY;
				float velZ;
				float life;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 col : TEXCOORD0;
			};

			float4 _Color1;
			float4 _Color2;
			float _MaxLife;
			StructuredBuffer<Particle3D> particleBuffer;

			v2f vert(uint vertex_id : SV_VertexID, uint instance_id : SV_InstanceID)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(float4(
					particleBuffer[instance_id].posX,
					particleBuffer[instance_id].posY,
					particleBuffer[instance_id].posZ,
					1));
				o.col = lerp(_Color1, _Color2, particleBuffer[instance_id].life / _MaxLife);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return i.col;
				//return _Color1;
			}
			ENDCG
		}
	}
}