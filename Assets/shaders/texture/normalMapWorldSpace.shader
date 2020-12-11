Shader "Unlit/normalMapWolrdSpace"
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
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				//TANGENT_SPACE_ROTATION;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
			    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			    
			    
			    fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			    fixed3 tangentNomal = UnpackNormal(packedNormal);
			    tangentNomal.xy *= _BumpScale;
			    tangentNomal.z = sqrt(1-saturate(dot(tangentNomal.xy, tangentNomal.xy)));
			    
			    
			    //tangentNomal = normalize(half3(dot(i.TtoW0.xyz, tangentNomal), dot(i.TtoW1.xyz, tangentNomal),dot(i.TtoW2.xyz, tangentNomal)));
			    float3x3 ratation = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
			    tangentNomal = mul(ratation, tangentNomal);
			    
			    
			    
				
                // Use the texture to sample the diffuse color
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed halfLambert = dot(tangentNomal, lightDir) * 0.5 +0.5;
                fixed lambert = saturate(dot(tangentNomal, lightDir));
                fixed3 diffuse = _LightColor0.rgb * albedo * lambert;
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNomal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
