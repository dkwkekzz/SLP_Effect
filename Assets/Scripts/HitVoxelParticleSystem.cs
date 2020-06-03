using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public struct VParticle_t
{
	public Vector3 position;
	public Vector3 size;
	public Quaternion rotation;
	public Vector3 velocity;
	public float speed;
};

public class HitVoxelParticleSystem : MonoBehaviour
{
	#region Shader property keys

	protected const string kSetupKernelKey = "Setup", kUpdateKernelKey = "Update";

	#endregion
	
	public ComputeShader Updater;

	[Header("ParticleSystem")]
	public bool Reset;
	public bool OnRunning;
	public Vector2 UnitLength;
	public Vector2 ForceDelta;
	public float ForceLength;
	public Vector2 Spin;
	public float Gravity;
	public Color Color;
	public Texture2D MainTex;

	protected Kernel setupKernel, updateKernel;
	private ComputeBuffer particleBuffer, normalBuffer;
	private MeshFilter filter;
	private new Renderer renderer;
	private MaterialPropertyBlock block;

	// Use this for initialization
	void Start()
	{
		filter = GetComponent<MeshFilter>();

		var pointMesh = filter.sharedMesh;
		particleBuffer = new ComputeBuffer(pointMesh.vertexCount, Marshal.SizeOf(typeof(VParticle_t)));
		normalBuffer = new ComputeBuffer(pointMesh.vertexCount, Marshal.SizeOf(typeof(Vector3)));
		normalBuffer.SetData(pointMesh.normals);

		setupKernel = new Kernel(Updater, kSetupKernelKey);
		updateKernel = new Kernel(Updater, kUpdateKernelKey);

		block = new MaterialPropertyBlock();
		renderer = GetComponent<Renderer>();
		renderer.GetPropertyBlock(block);

		Setup();
	}

	private void OnDestroy()
	{
		particleBuffer?.Release();
		normalBuffer?.Release();
	}

	// Update is called once per frame
	void Update()
	{
		if (Reset)
		{
			Reset = false;
			Setup();
			return;
		}

		if (!OnRunning) return;

		Compute(updateKernel, Time.deltaTime);
	
		block.SetBuffer(SPK._ParticleBuffer, particleBuffer);
		renderer.SetPropertyBlock(block);
	}
	
	void Setup()
	{
		block.SetColor(SPK._Color, Color);
		if (MainTex != null)
			block.SetTexture(SPK._MainTex, MainTex);

		Updater.SetBuffer(setupKernel.Index, SPK._ParticleBuffer, particleBuffer);
		Updater.SetInt(SPK._ParticleCount, particleBuffer.count);
		Updater.SetBuffer(setupKernel.Index, SPK._NormalBuffer, normalBuffer);
		Updater.SetVector(SPK._InitPosition, transform.position);
		Updater.SetVector(SPK._UnitLength, UnitLength);
		Updater.SetVector(SPK._ForceDelta, ForceDelta);
		Updater.SetFloat(SPK._ForceLength, ForceLength);

		Updater.Dispatch(setupKernel.Index, particleBuffer.count / (int)setupKernel.ThreadX + 1, (int)setupKernel.ThreadY, (int)setupKernel.ThreadZ);
	}
	
	void Compute(Kernel kernel, float dt)
	{
		Updater.SetBuffer(kernel.Index, SPK._ParticleBuffer, particleBuffer);
		Updater.SetInt(SPK._ParticleCount, particleBuffer.count);
		Updater.SetFloat(SPK._DT, dt);
		Updater.SetVector(SPK._Spin, Spin);
		Updater.SetFloat(SPK._Gravity, Gravity);

		Updater.Dispatch(kernel.Index, particleBuffer.count / (int)kernel.ThreadX + 1, (int)kernel.ThreadY, (int)kernel.ThreadZ);
	}
}
