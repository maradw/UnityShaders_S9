Shader "LightsToObject"
{
    Properties
    {
        _MainTex("Flag Texture", 2D) = "white" {}
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(1, 128)) = 32
        _AmbientColor("Ambient Color", Color) = (0.2, 0.2, 0.2, 1) // Color ambiental
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

                sampler2D _MainTex;

                float _Shininess;
                float4 _AmbientColor;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD1;
                    float3 worldPos : TEXCOORD2;
                    float3 viewDir : TEXCOORD3;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    float4 texColor = tex2D(_MainTex, i.uv);
                    float3 ambient = _AmbientColor.rgb * texColor.rgb;
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float NdotL = max(0, dot(i.worldNormal, lightDir));
                    float3 diffuse = texColor.rgb * _LightColor0.rgb * NdotL;
                    float3 reflectDir = reflect(-lightDir, i.worldNormal);
                    float specFactor = pow(max(dot(reflectDir, i.viewDir), 0), _Shininess);
                    float3 specular = _SpecColor.rgb * specFactor;
                    float3 color = ambient + diffuse + specular;
                    return float4(color, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
