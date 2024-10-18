Shader "Prueba 1"
{
    Properties
    {
       _MainColor("Color", Color) = (0,1,0,1) // Color con alpha
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //Blend SrcAlpha OneMinusSrcAlpha // Habilita el blending para la transparencia

        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            // Hacer que la niebla funcione
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

            // Declarar la variable _MainColor aquí
            fixed4 _MainColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Usa el color definido en las propiedades
                return _MainColor; // Aplica el color y la transparencia
            }
            ENDCG
        }
    }
}
