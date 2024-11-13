Shader "Custom/CombinedMapShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _SpecularMap("Specular Map", 2D) = "white" {}
        _Shininess("Shininess", Range(0.03, 1.0)) = 0.078
        _EmissionMap("Emission Map", 2D) = "black" {}
        _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
        _EmissionStrength("Emission Strength", Range(0, 10)) = 1.0
        _HeightMap("Height Map", 2D) = "black" {}
        _HeightScale("Height Scale", Range(0, 0.1)) = 0.05
        _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Color("Tint Color", Color) = (1, 1, 1, 1)
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 300

            CGPROGRAM
            #pragma surface surf BlinnPhong
            #pragma target 3.0

            // Definir propiedades y variables de textura aquí
            sampler2D _MainTex;
            sampler2D _SpecularMap;
            sampler2D _EmissionMap;
            sampler2D _HeightMap;
            sampler2D _OcclusionMap;
            sampler2D _NormalMap;
            float _Shininess;
            float4 _EmissionColor;
            float _EmissionStrength;
            float _HeightScale;
            float _OcclusionStrength;
            float4 _Color;

            struct Input
            {
                float2 uv_MainTex;
                float2 uv_SpecularMap;
                float2 uv_EmissionMap;
                float2 uv_HeightMap;
                float2 uv_OcclusionMap;
                float2 uv_NormalMap;
                float3 viewDir;
            };

            void surf(Input IN, inout SurfaceOutput o)
            {
                // Base Texture with Tint Color
                fixed4 texColor = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = texColor.rgb;

                // Specular Mapping
                float specular = tex2D(_SpecularMap, IN.uv_SpecularMap).r;
                o.Specular = specular;
                o.Gloss = _Shininess;

                // Emission Mapping
                float3 emission = tex2D(_EmissionMap, IN.uv_EmissionMap).rgb * _EmissionColor.rgb * _EmissionStrength;
                o.Emission = emission;

                // Parallax (Height) Mapping
                float height = tex2D(_HeightMap, IN.uv_HeightMap).r;
                float2 parallaxOffset = (IN.viewDir.xy * height * _HeightScale) / IN.viewDir.z;
                float2 parallaxUV = IN.uv_MainTex + parallaxOffset;

                // Occlusion Mapping
                float occlusion = tex2D(_OcclusionMap, IN.uv_OcclusionMap).r;
                occlusion = 1.0 - (1.0 - occlusion) * _OcclusionStrength;
                o.Albedo *= occlusion;

                // Normal Mapping
                fixed3 normalMap = tex2D(_NormalMap, IN.uv_NormalMap).rgb * 2.0 - 1.0;
                o.Normal = normalize(mul(normalMap, o.Normal));

                // Final Albedo and Color Application
                o.Albedo *= tex2D(_MainTex, parallaxUV).rgb;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
