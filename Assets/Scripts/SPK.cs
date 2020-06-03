using UnityEngine;
using System.Collections;

public static class SPK
{
	public static readonly int _Life = Shader.PropertyToID("_Life");
	public static readonly int _ParticleBuffer = Shader.PropertyToID("_ParticleBuffer");
	public static readonly int _ParticleCount = Shader.PropertyToID("_ParticleCount");
	public static readonly int _NormalBuffer = Shader.PropertyToID("_NormalBuffer");
	public static readonly int _DT = Shader.PropertyToID("_DT");
	public static readonly int _InitPosition = Shader.PropertyToID("_InitPosition");
	public static readonly int _UnitLength = Shader.PropertyToID("_UnitLength");
	public static readonly int _ForceDelta = Shader.PropertyToID("_ForceDelta");
	public static readonly int _ForceLength = Shader.PropertyToID("_ForceLength");
	public static readonly int _Spin = Shader.PropertyToID("_Spin");
	public static readonly int _Gravity = Shader.PropertyToID("_Gravity");

	public static readonly int _Color = Shader.PropertyToID("_Color");
	public static readonly int _MainTex = Shader.PropertyToID("_MainTex");
}
