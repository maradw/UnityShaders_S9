Shader "Custom/CombinedMapShader_WithHeightMap"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _SpecularMap("Specular Map", 2D) = "white" {}
        _Shininess("Shininess", Range(0.03, 1.0)) = 0.078
        _EmissionMap("Emission Map", 2D) = "black" {}
        _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
        _EmissionStrength("Emission Strength", Range(0, 10)) = 1.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1.0
        _HeightMap("Height Map", 2D) = "black" {}
        _HeightScale("Height Scale", Range(0.0, 0.1)) = 0.05
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 300

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 3.0

                sampler2D _MainTex;
                sampler2D _SpecularMap;
                sampler2D _EmissionMap;
                sampler2D _NormalMap;
                sampler2D _OcclusionMap;
                sampler2D _HeightMap;

                float _Shininess;
                float4 _EmissionColor;
                float _EmissionStrength;
                float _OcclusionStrength;
                float _HeightScale;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                    float4 tangent : TANGENT;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 viewDir : TEXCOORD1;
                    float3 worldNormal : TEXCOORD2;
                    float3 worldTangent : TEXCOORD3;
                    float3 worldBinormal : TEXCOORD4;
                    float3 worldPos : TEXCOORD5;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;

                    o.worldNormal = normalize(mul((float3x3)unity_WorldToObject, v.normal));
                    o.worldTangent = normalize(mul((float3x3)unity_WorldToObject, v.tangent.xyz));
                    o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                    // Calcular la dirección de la cámara para Parallax Mapping
                    o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);

                    return o;
                }

                float2 ParallaxMapping(float2 uv, float3 viewDir)
                {
                    // Obtener la altura desde el Height Map
                    float height = tex2D(_HeightMap, uv).r;

                    // Ajustar las coordenadas UV basadas en la altura y la escala de desplazamiento
                    float2 offset = viewDir.xy * ((height - 0.5) * _HeightScale);
                    return uv + offset;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Aplicar el Parallax Mapping para ajustar las coordenadas UV
                    float2 parallaxUV = ParallaxMapping(i.uv, i.viewDir);

                    // Texturas y mapas
                    float4 mainColor = tex2D(_MainTex, parallaxUV);
                    float3 normal = normalize(tex2D(_NormalMap, parallaxUV).xyz * 2.0 - 1.0);
                    float3 specularColor = tex2D(_SpecularMap, parallaxUV).rgb;
                    float3 emission = tex2D(_EmissionMap, parallaxUV).rgb * _EmissionColor.rgb * _EmissionStrength;
                    float occlusion = lerp(1.0, tex2D(_OcclusionMap, parallaxUV).r, _OcclusionStrength);

                    // Especularidad
                    float3 viewDir = normalize(i.viewDir);
                    float3 reflectDir = reflect(-viewDir, normal);
                    float3 lightDir = normalize(float3(0.0, 0.0, 1.0));
                    float specular = pow(saturate(dot(reflectDir, lightDir)), _Shininess);

                    // Color final
                    float3 color = mainColor.rgb * occlusion + specular * specularColor + emission;

                    return float4(color, mainColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
