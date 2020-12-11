Shader "Unlit/diffuse_pixel2"
{
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldLight : TEXCOORD1;
				float3 ambient:TEXCOORD2;
				float3 diffuse:TEXCOORD3;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);

				// Transform the normal from object space to world space
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.worldLight = normalize(_WorldSpaceLightPos0.xyz);
                o.ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                o.diffuse =  _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.worldNormal, o.worldLight));
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				// Get ambient term
				//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Get the normal in world space
				// Get the light direction in world space
				
				// Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, i.worldLight));
				
				//fixed3 color = i.ambient + i.diffuse;
				fixed3 color = i.ambient + diffuse;
				
				return fixed4(color, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
	
}
