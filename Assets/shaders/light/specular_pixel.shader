// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/specular_pixel"
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
                fixed3 worldNormal:TEXCOORD0;
                fixed3 worldLight:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };
            
            v2f vert(a2v a) {
                v2f v;
                v.pos = UnityObjectToClipPos(a.vertex);
                v.worldNormal = normalize(mul(a.normal, (float3x3)unity_WorldToObject));
                v.worldLight = normalize(_WorldSpaceLightPos0.xyz);
                v.worldPos = mul(unity_ObjectToWorld, a.vertex).xyz;
                
                return v;
            };
            
			fixed4 frag(v2f v):SV_Target {
			    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			    
			    fixed3 halfLambert = dot(v.worldNormal, v.worldLight) * 0.5 + 0.5;
			    fixed3 lambert = saturate(dot(v.worldNormal, v.worldLight));
			    fixed3 diffuse = _LightColor0.rgb * _diffuse.rgb * halfLambert;
			    
			    fixed3 reflectDir = normalize(reflect(-v.worldLight, v.worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - v.worldPos);
                fixed3 specular = _LightColor0.rgb * _specular.rgb * pow(saturate(dot(viewDir, reflectDir)), _gloss);
                fixed3 color = ambient + diffuse + specular;
			    return fixed4(color, 1.0);
			};
			
			ENDCG
		}
	}
	Fallback "Specular"
}
