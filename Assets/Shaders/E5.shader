Shader "Prueba5"
{
    Properties
    {
        _Text1("Texture", 2D) = "white" {}
        _Text2("Texture", 2D) = "white" {}
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
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _Text1;
            sampler2D _Text2;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 t1 = tex2D(_Text1, i.uv);
                fixed4 t2 = tex2D(_Text2, i.uv);
                fixed4 txt = t1 * t2;
                return txt;
            }
            ENDCG
        }
    }
}
