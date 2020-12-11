// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/specular_vertex"
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
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			fixed4 _diffuse;
			fixed4 _specular;
			float _gloss;
            
            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                
            };
            
            struct v2f {
                float4 pos:SV_POSITION;
                fixed3 color:COLOR;
            };
            
            v2f vert(a2v a) {
                v2f v;
                v.pos = UnityObjectToClipPos(a.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed3 worldNormal = normalize(mul(a.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfLambert = dot(worldNormal, worldLight) * 0.5 + 0.5;
                fixed3 lambert = saturate(dot(worldNormal, worldLight));
                fixed3 diffuse = _LightColor0.rgb * _diffuse.rgb * lambert;
                
                fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
                fixed3 worldPos = mul(unity_ObjectToWorld, a.vertex).xyz;
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                fixed3 specular = _LightColor0.rgb * _specular.rgb * pow(saturate(dot(viewDir, reflectDir)), _gloss);
                v.color = ambient + diffuse + specular;
                return v;
            };
            
			fixed4 frag(v2f v):SV_Target {
			    return fixed4(v.color, 1.0);
			};
			
			ENDCG
		}
	}
	Fallback "Specular"
}
