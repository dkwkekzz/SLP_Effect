// - Sources:
//      Standard geometry shader example
//      https://github.com/keijiro/StandardGeometryShader

Shader "SPL/VoxelParticleLit"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		// Ambient light is applied uniformly to all surfaces on the object.
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		// Controls the size of the specular reflection.
		_Glossiness("Glossiness", Float) = 32
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Float) = 0.716
		// Control how smoothly the rim blends when approaching unlit
		// parts of the surface.
		_RimThreshold("Rim Threshold", Float) = 0.1
		_ToonIntensity("Toon Intensity", Float) = 0.1
			
		[Space]
		_Size ("Size", Float) = 0.1
    }

    SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque" 
			"RenderPipeline" = "UniversalRenderPipeline" 
			"IgnoreProjector" = "True"
		}

        // This shader only implements the deferred rendering pass (GBuffer
        // construction) and the shadow caster pass, so that it doesn't
        // support forward rendering.

		Cull off

        Pass
        {
			Tags
			{
				"LightMode" = "UniversalForward"
				"PassFlags" = "OnlyDirectional"
			}

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex Vertex
            #pragma geometry GeometryQuad
            #pragma fragment Fragment
			// Compile multiple versions of this shader depending on lighting settings.
			#pragma multi_compile_fwdbase
            #include "VoxelParticle.cginc"
            ENDCG
        }

		// Shadow casting support.
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
