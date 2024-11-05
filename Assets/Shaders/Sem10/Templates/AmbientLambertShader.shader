Shader "Custom/AmbientLambertShader"
{
    Properties
    {
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
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
            };

            float4 _Color;
            float4 _AmbientColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 ambient = _Color.rgb * _AmbientColor.rgb;  // Luz ambiental
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);// Luz direccional (Lambert)
                float NdotL = max(0, dot(i.worldNormal, lightDir));
                float3 diffuse = _Color.rgb * _LightColor0.rgb * NdotL;
                float3 finalColor = ambient + diffuse;  // Combina la luz ambiental y la difusa

                return float4(finalColor, _Color.a);
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}
