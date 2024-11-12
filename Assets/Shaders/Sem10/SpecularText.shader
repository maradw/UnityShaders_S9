Shader "SpecularText"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _CustomSpecColor("Specular Color", Color) = (1, 1, 1, 1)
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1)
        _Shininess("Shininess", Range(1, 128)) = 32
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
                    float2 uv : TEXCOORD0; 
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                    float3 viewDir : TEXCOORD2;
                    float2 uv : TEXCOORD3; 
                };

                sampler2D _MainTex;
                float4 _Color;
                float4 _CustomSpecColor;
                float4 _AmbientColor;
                float _Shininess;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);
                    o.uv = v.uv;
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    float4 texColor = tex2D(_MainTex, i.uv);
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float NdotL = max(0, dot(i.worldNormal, lightDir));
                    float3 diffuse = texColor.rgb * _LightColor0.rgb * NdotL;
                    float3 reflectDir = reflect(-lightDir, i.worldNormal);
                    float specFactor = pow(max(dot(reflectDir, i.viewDir), 0), _Shininess);
                    float3 specular = _CustomSpecColor.rgb * specFactor;
                    float3 ambient = texColor.rgb * _AmbientColor.rgb;
                    float3 color = ambient + diffuse + specular;
                    return float4(color, texColor.a * _Color.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
