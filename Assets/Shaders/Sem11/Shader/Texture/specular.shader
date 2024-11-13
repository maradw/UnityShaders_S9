Shader "Custom/SpecularMapShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}         // Textura principal
        _SpecularMap("Specular Map", 2D) = "white" {}     // Mapa especular
        _Shininess("Shininess", Range(0.03, 1.0)) = 0.078 // Brillo especular
        _Color("Tint Color", Color) = (1, 1, 1, 1)        // Color base
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 300

            CGPROGRAM
            #pragma surface surf BlinnPhong

            sampler2D _MainTex;
            sampler2D _SpecularMap;
            float _Shininess;
            float4 _Color;

            struct Input
            {
                float2 uv_MainTex;        // Coordenadas UV para la textura principal
                float2 uv_SpecularMap;    // Coordenadas UV para el mapa especular
            };

            void surf(Input IN, inout SurfaceOutput o)
            {
                // Color base y tinte
                fixed4 texColor = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = texColor.rgb;

                // Valor especular del mapa especular (sólo canal rojo)
                float specular = tex2D(_SpecularMap, IN.uv_SpecularMap).r;
                o.Specular = specular; // Controla la intensidad especular basada en el mapa

                // Controla la intensidad del brillo especular (Shininess)
                o.Gloss = _Shininess;
            }
            ENDCG
        }
            FallBack "Specular"
}
