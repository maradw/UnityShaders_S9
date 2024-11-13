Shader "Custom/ParallaxHeightMapShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}        // Textura principal
        _HeightMap("Height Map", 2D) = "white" {}        // Mapa de altura
        _HeightScale("Height Scale", Range(0, 0.1)) = 0.05 // Escala de altura
        _Color("Tint Color", Color) = (1, 1, 1, 1)       // Color base
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
                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 viewDir : TEXCOORD1;
                };

                sampler2D _MainTex;
                sampler2D _HeightMap;
                float _HeightScale;
                float4 _Color;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;

                    // Calcular la dirección de la vista para el parallax
                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                    o.viewDir = viewDir;

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Obtener el valor de altura del mapa de alturas
                    float heightValue = tex2D(_HeightMap, i.uv).r;

                // Calcular el desplazamiento de parallax
                float2 parallaxOffset = (heightValue - 0.5) * _HeightScale * i.viewDir.xy;
                float2 displacedUV = i.uv + parallaxOffset;

                // Obtener el color de la textura principal en las coordenadas desplazadas y aplicar el tinte
                float4 texColor = tex2D(_MainTex, displacedUV) * _Color;

                return texColor;
            }
            ENDCG
        }
        }
            FallBack "Diffuse"
}
