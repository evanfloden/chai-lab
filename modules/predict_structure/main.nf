process PREDICT_STRUCTURE {
    tag "$meta.id"
    label 'process_high'  // This process likely needs significant computational resources
    
    conda "${moduleDir}/environment.yml"
    //container 'chailab:latest'  // Using the same container as specified in base config
    
    input:
    tuple val(meta), path(fasta)
    path(msa_dir)
    path(constraints)
    
    output:
    tuple val(meta), path("${meta.id}/ranked_*.cif"), emit: structures
    tuple val(meta), path("${meta.id}/ranking_data.json"), emit: rankings
    tuple val(meta), path("${meta.id}/msa_coverage.png"), optional: true, emit: msa_plot
    path "versions.yml", emit: versions

    script:
    """
    #!/usr/bin/env python3
    import sys
    from pathlib import Path
    from chai_lab.chai1 import run_inference
    import torch

    # Set up output directory
    output_dir = Path("${meta.id}")
    output_dir.mkdir(exist_ok=True)

    # Run structure prediction
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    run_inference(
        fasta_file=Path("${fasta}"),
        output_dir=output_dir,
        # 'default' setup
        num_trunk_recycles=3,
        num_diffn_timesteps=200,
        seed=42,
        device=device,
        use_esm_embeddings=True,
    )

    # Create versions file
    with open("versions.yml", "w") as f:
        f.write('"${task.process}":\\n')
        f.write('    python: "' + sys.version.split()[0] + '"\\n')
        f.write('    torch: "' + torch.__version__ + '"\\n')
    """
}
