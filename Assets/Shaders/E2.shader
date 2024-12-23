Shader "Prueba2"
{
    Properties
    {
         _ColorA("Color", Color) = (1,0.5,0,1)
         _ColorB("Color", Color) = (0.5,0,0.7,1)
         _Interpolation("Interpolation", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            fixed4 _ColorA;
            fixed4 _ColorB;
            float _Interpolation;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 interpolated = lerp(_ColorA, _ColorB, _Interpolation);
                return interpolated;
               
            }
            ENDCG
        }
    }
}
