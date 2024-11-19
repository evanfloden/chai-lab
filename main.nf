#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/*
 * Import modules
 */
include { PREDICT_STRUCTURE } from './modules/predict_structure'

/*
 * Pipeline parameters
 */
params.fasta = "${baseDir}/examples/fasta/example.fa"
params.msa_dir = null
params.constraints = null
params.outdir = 'results'
params.help = false


/*
 * Main workflow
 */
workflow {

    // Show help message if --help specified or if required parameters are not provided
    if (params.help || params.fasta == null) {
        helpMessage()
        exit(params.help ? 0 : 1)
    }

    /*
    * Log info
    */
    log.info(
        """
         Chai Lab - N F   P I P E L I N E
         ===================================
         fasta       : ${params.fasta}
         msa_dir     : ${params.msa_dir}
         constraints : ${params.constraints}
         outdir      : ${params.outdir}
         """.stripIndent()
    )


    // Input channel for FASTA files
    Channel
        .fromPath(params.fasta)
        .map { fasta -> [[id: fasta.simpleName], fasta] }
        .set { fasta_ch }

    // Optional MSA directory
    msa_dir = params.msa_dir ? Channel.fromPath(params.msa_dir) : Channel.value([])

    // Optional constraints file
    constraints = params.constraints ? Channel.fromPath(params.constraints) : Channel.value([])

    // Run structure prediction
    PREDICT_STRUCTURE(fasta_ch, msa_dir, constraints)

    /*
    * Completion notification
    */
    workflow.onComplete {
        log.info(
            """
        Pipeline execution summary
        ---------------------------
        Completed at : ${workflow.complete}
        Duration     : ${workflow.duration}
        Success      : ${workflow.success}
        workDir      : ${workflow.workDir}
        exit status  : ${workflow.exitStatus}
        """
        )
    }
}


/*
 * Print help message
 */
def helpMessage() {
    log.info(
        """
    =========================================
    chai-lab v${workflow.manifest.version}
    =========================================

    Usage:
    nextflow run main.nf [options]

    Options:
        --fasta        Path to input FASTA file (required)
        --msa_dir      Directory containing MSA files (optional)
        --constraints  Path to constraints file (optional)
        --outdir       The output directory where the results will be saved
        --help         Show this message
    """.stripIndent()
    )
}
