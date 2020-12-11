Shader "Unlit/normalMapTangentSpace"
{
	Properties
	{
	    _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap("normal map", 2D) = "bump"{}
		_BumpScale("bump scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader
	{
		
		Pass
		{
		    Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
			};

			
			v2f vert (a2v v)
			{
			    
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				TANGENT_SPACE_ROTATION;
				o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
				o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			
			   fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			   fixed3 tangentNomal = UnpackNormal(packedNormal);
			   tangentNomal.xy *= _BumpScale;
			   tangentNomal.z = sqrt(1-saturate(dot(tangentNomal.xy, tangentNomal.xy)));
			    
				
               // Use the texture to sample the diffuse color
               fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
               fixed halfLambert = dot(tangentNomal, i.lightDir) * 0.5 +0.5;
               fixed lambert = saturate(dot(tangentNomal, i.lightDir));
               fixed3 diffuse = _LightColor0.rgb * albedo * lambert;
               fixed3 halfDir = normalize(i.lightDir + i.viewDir);
               fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNomal, halfDir)), _Gloss);
               return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
