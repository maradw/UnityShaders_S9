Shader "AmbientText"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _AmbientColor("Ambient Light Color", Color) = (1, 1, 1, 1)
        _Color("Base Color", Color) = (1, 1, 1, 1)
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };
                sampler2D _MainTex;       
                float4 _MainTex_ST;       
                float4 _AmbientColor;     
                float4 _Color;            
                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);     
                    return o;
                }
                float4 frag(v2f i) : SV_Target
                {
                    float4 texColor = tex2D(_MainTex, i.uv);
                    float4 resultColor = texColor * _AmbientColor * _Color;
                    return resultColor;
                }
                ENDCG
            }
        }
                    FallBack "Diffuse"
}
