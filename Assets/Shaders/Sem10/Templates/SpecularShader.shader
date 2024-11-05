Shader "Custom/SpecularShader"
{
    Properties
    {
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        _CustomSpecColor ("Specular Color", Color) = (1, 1, 1, 1) // Cambiado a _CustomSpecColor
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1)
        _Shininess ("Shininess", Range(1, 128)) = 32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            float4 _Color;
            float4 _CustomSpecColor;
            float4 _AmbientColor;
            float _Shininess;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));// Calcular la normal y la posici�n en el espacio mundial
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);// Direcci�n de la vista desde el espacio mundial
                return o;
            }
            float4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);// Color difuso
                float NdotL = max(0, dot(i.worldNormal, lightDir));
                float3 diffuse = _Color.rgb * _LightColor0.rgb * NdotL;
                float3 reflectDir = reflect(-lightDir, i.worldNormal); // Componente especular
                float specFactor = pow(max(dot(reflectDir, i.viewDir), 0), _Shininess);
                float3 specular = _CustomSpecColor.rgb * specFactor; // Cambiado a _CustomSpecColor
                float3 ambient = _Color.rgb * _AmbientColor.rgb;// Luz ambiental
                float3 color = ambient + diffuse + specular;// Color final
                return float4(color, _Color.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
