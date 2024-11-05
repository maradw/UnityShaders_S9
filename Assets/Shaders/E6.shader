Shader "Prueba6"
{
   Properties
    {
        _MainTex ("Flag Texture", 2D) = "white" {} 
        _WindStrength("Wind Strength", Float) = 1.0
        _WaveSpeed("Wave Speed", Float) = 1.0
        _WaveFrequency("Wave Frequency", Float) = 2.0
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
             sampler2D _MainTex;
             float _WindStrength;
             float _WaveSpeed;
             float _WaveFrequency;
             struct appdata
             {
                 float4 vertex : POSITION;
                 float2 uv : TEXCOORD0;
             };
             struct v2f
             {
                 float2 uv : TEXCOORD0;
                 float4 pos : SV_POSITION;
             };
             v2f vert (appdata v)
             {
                 v2f o;
                 // Aplicar deformación senoidal
                 float wave = sin(v.vertex.x * _WaveFrequency + _Time.y * _WaveSpeed) * _WindStrength;
                 // Desplazar los vértices dirección del viento
                 v.vertex.xyz += wave;
                 o.pos = UnityObjectToClipPos(v.vertex);
                 o.uv = v.uv;
                 return o;
             }
             fixed4 frag (v2f i) : SV_Target
             {
                 return tex2D(_MainTex, i.uv);
             }
             ENDCG
        }
    }
}



