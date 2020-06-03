// - Sources:
//      Standard geometry shader example
//      https://github.com/keijiro/StandardGeometryShader

#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;

float4 _Color;

float4 _AmbientColor;

float4 _SpecularColor;
float _Glossiness;

float4 _RimColor;
float _RimAmount;
float _RimThreshold;
float _ToonIntensity;

float _Size;

#include "Quaternion.cginc"
#include "VParticle.cginc"

StructuredBuffer<VParticle> _ParticleBuffer;

// Vertex input attributes
struct Attributes
{
    float4 position : POSITION;
    float3 size : NORMAL;
    float4 rotation : TANGENT;
};

// Fragment varyings
struct Varyings
{
	float4 pos : SV_POSITION;
	float3 worldNormal : NORMAL;
	float2 uv : TEXCOORD0;
	float3 viewDir : TEXCOORD1;
	// Macro found in Autolight.cginc. Declares a vector4
	// into the TEXCOORD2 semantic with varying precision 
	// depending on platform target.
	SHADOW_COORDS(2)
};

//
// Vertex stage
//

Attributes Vertex(Attributes input, uint vid : SV_VertexID)
{
    VParticle particle = _ParticleBuffer[vid];
    input.position = float4(particle.position, 1);
    input.size = particle.size;
    input.rotation = particle.rotation;
    return input;
}

//
// Geometry stage
//

Varyings VertexOutput(in Varyings o, float4 pos, float3 wnrm, float2 texcoord)
{
	o.pos = UnityObjectToClipPos(pos);
	o.worldNormal = wnrm;
	o.uv = texcoord; 
	o.viewDir = WorldSpaceViewDir(pos);
	TRANSFER_SHADOW(o)
    return o;
}

void addFace (inout TriangleStream<Varyings> OUT, float4 p[4], float3 normal)
{
    float3 wnrm = UnityObjectToWorldNormal(normal);
    Varyings o = VertexOutput(o, p[0], wnrm, float2(1.0f, 0.0f));
    OUT.Append(o);

    o = VertexOutput(o, p[1], wnrm, float2(1.0f, 1.0f));
    OUT.Append(o);

    o = VertexOutput(o, p[2], wnrm, float2(0.0f, 0.0f));
    OUT.Append(o);

    o = VertexOutput(o, p[3], wnrm, float2(0.0f, 1.0f));
    OUT.Append(o);

    OUT.RestartStrip();
}

[maxvertexcount(24)]
void GeometryCube (point Attributes IN[1], inout TriangleStream<Varyings> OUT) {

    float3 halfS = 0.5f * IN[0].size;

    float3 pos = IN[0].position.xyz;
    float3 right = rotate_vector(float3(1, 0, 0), IN[0].rotation) * halfS.x;
    float3 up = rotate_vector(float3(0, 1, 0), IN[0].rotation) * halfS.y;
    float3 forward = rotate_vector(float3(0, 0, 1), IN[0].rotation) * halfS.z;

    float4 v[4];

	// forward
    v[0] = float4(pos + forward + right - up, 1.0f);
    v[1] = float4(pos + forward + right + up, 1.0f);
    v[2] = float4(pos + forward - right - up, 1.0f);
    v[3] = float4(pos + forward - right + up, 1.0f);
    addFace(OUT, v, normalize(forward));

	// back
    v[0] = float4(pos - forward - right - up, 1.0f);
    v[1] = float4(pos - forward - right + up, 1.0f);
    v[2] = float4(pos - forward + right - up, 1.0f);
    v[3] = float4(pos - forward + right + up, 1.0f);
    addFace(OUT, v, -normalize(forward));

	// up
    v[0] = float4(pos - forward + right + up, 1.0f);
    v[1] = float4(pos - forward - right + up, 1.0f);
    v[2] = float4(pos + forward + right + up, 1.0f);
    v[3] = float4(pos + forward - right + up, 1.0f);
    addFace(OUT, v, normalize(up));

	// down
    v[0] = float4(pos + forward + right - up, 1.0f);
    v[1] = float4(pos + forward - right - up, 1.0f);
    v[2] = float4(pos - forward + right - up, 1.0f);
    v[3] = float4(pos - forward - right - up, 1.0f);
    addFace(OUT, v, -normalize(up));

	// left
    v[0] = float4(pos + forward - right - up, 1.0f);
    v[1] = float4(pos + forward - right + up, 1.0f);
    v[2] = float4(pos - forward - right - up, 1.0f);
    v[3] = float4(pos - forward - right + up, 1.0f);
    addFace(OUT, v, -normalize(right));

	// right
    v[0] = float4(pos - forward + right + up, 1.0f);
    v[1] = float4(pos + forward + right + up, 1.0f);
    v[2] = float4(pos - forward + right - up, 1.0f);
    v[3] = float4(pos + forward + right - up, 1.0f);
    addFace(OUT, v, normalize(right));
};

[maxvertexcount(3)]
void GeometryTriangle(point Attributes IN[1], inout TriangleStream<Varyings> OUT) {

	float3 halfS = 0.5f * IN[0].size;

	float3 pos = IN[0].position.xyz;
	float3 right = rotate_vector(float3(1, 0, 0), IN[0].rotation) * halfS.x;
	float3 up = rotate_vector(float3(0, 1, 0), IN[0].rotation) * halfS.y;
	float3 forward = rotate_vector(float3(0, 0, 1), IN[0].rotation) * halfS.z;
	float3 normal = normalize(forward);

	float4 v0 = float4(pos + right - up, 1.0f);
	float4 v1 = float4(pos + right + up, 1.0f);
	float4 v2 = float4(pos - right - up, 1.0f);

	float3 wnrm = UnityObjectToWorldNormal(normal);
	Varyings o = VertexOutput(o, v0, wnrm, float2(1.0f, 0.0f));
	OUT.Append(o);

	o = VertexOutput(o, v1, wnrm, float2(1.0f, 1.0f));
	OUT.Append(o);

	o = VertexOutput(o, v2, wnrm, float2(0.0f, 0.0f));
	OUT.Append(o);

	OUT.RestartStrip();
};

[maxvertexcount(4)]
void GeometryQuad(point Attributes IN[1], inout TriangleStream<Varyings> OUT) {

	float3 halfS = 0.5f * IN[0].size;

	float3 pos = IN[0].position.xyz;
	float3 right = rotate_vector(float3(1, 0, 0), IN[0].rotation) * halfS.x;
	float3 up = rotate_vector(float3(0, 1, 0), IN[0].rotation) * halfS.y;
	float3 forward = rotate_vector(float3(0, 0, 1), IN[0].rotation) * halfS.z;
	float3 normal = normalize(forward);

	float4 v[4];

	// forward
	v[0] = float4(pos + forward + right - up, 1.0f);
	v[1] = float4(pos + forward + right + up, 1.0f);
	v[2] = float4(pos + forward - right - up, 1.0f);
	v[3] = float4(pos + forward - right + up, 1.0f);
	addFace(OUT, v, normalize(forward));
};

//
// Fragment phase
//

fixed4 Fragment(Varyings i) : SV_Target
{ 
	float3 normal = normalize(i.worldNormal);
	float3 viewDir = normalize(i.viewDir);

	// Lighting below is calculated using Blinn-Phong,
	// with values thresholded to creat the "toon" look.
	// https://en.wikipedia.org/wiki/Blinn-Phong_shading_model

	// Calculate illumination from directional light.
	// _WorldSpaceLightPos0 is a vector pointing the OPPOSITE
	// direction of the main directional light.
	float NdotL = dot(_WorldSpaceLightPos0, normal);

	// Samples the shadow map, returning a value in the 0...1 range,
	// where 0 is in the shadow, and 1 is not.
	float shadow = SHADOW_ATTENUATION(i);
	// Partition the intensity into light and dark, smoothly interpolated
	// between the two to avoid a jagged break.
	float lightIntensity = smoothstep(0, _ToonIntensity, NdotL * shadow);
	// Multiply by the main directional light's intensity and color.
	float4 light = lightIntensity * _LightColor0;

	// Calculate specular reflection.
	float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
	float NdotH = dot(normal, halfVector);
	// Multiply _Glossiness by itself to allow artist to use smaller
	// glossiness values in the inspector.
	float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
	float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
	float4 specular = specularIntensitySmooth * _SpecularColor;

	// Calculate rim lighting.
	float rimDot = 1 - dot(viewDir, normal);
	// We only want rim to appear on the lit side of the surface,
	// so multiply it by NdotL, raised to a power to smoothly blend it.
	float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
	rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
	float4 rim = rimIntensity * _RimColor;

	float4 sample = tex2D(_MainTex, i.uv);

	return (light + _AmbientColor + specular + rim) * _Color * sample;
}