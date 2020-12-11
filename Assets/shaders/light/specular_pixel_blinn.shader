Shader "Unlit/specular_pixel_blinn"
{
	Properties
	{
		_diffuse ("Diffuse", Color) = (1,1,1,1)
		_specular("Specular", Color) = (1,1,1,1)
		_gloss("Gloss", Range(8.0, 256)) = 20
	}
	SubShader
	{
	
		Pass
		{
		    Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

            fixed4 _diffuse;
			fixed4 _specular;
			float _gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 worldLight:TEXCOORD0;
				fixed3 worldNormal:TEXCOORD1;
				fixed3 worldPos:TEXCOORD2;
			};

			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			    o.worldLight = normalize(WorldSpaceLightDir(v.vertex));
			    o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
			    
			    
				return o;
			}
			
			fixed4 frag (v2f v) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 halfLambert = dot(v.worldNormal, v.worldLight) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb * _diffuse.rgb * halfLambert;
				
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
				fixed3 halfDir = normalize(v.worldLight + viewDir);
				fixed3 specular = _LightColor0.rgb * _specular.rgb * pow(max(0, dot(v.worldNormal, halfDir)),_gloss);
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
