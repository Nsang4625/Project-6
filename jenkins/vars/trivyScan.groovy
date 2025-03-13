/**
 * Scans a Docker image using Trivy
 * 
 * @param config Map of configuration options:
 * - repository: Image repository name
 * - tag: Image tag
 * - registryType: Registry type(ecr | dockerhub)
 * - awsRegion: AWS region for ECR registry
 * - awsAccountId: AWS account ID for ECR registry
 */

def call(Map config = [:]) {
    validateInput()
    def outputFile = "trivy-scan-${env.GIT_COMMIT[0..8]}.json"
    def imageName = "${config.repository}:${config.tag}"
    pullImage(imageName)
    def exitCode = sh script: """
        trivy image \
            --severity CRITICAL,HIGH \
            --format json \
            --output ${outputFile} \
            --input ${imageName}.tar    
    """, returnStatus: true

    def result = readJSON file: outputFile
    handleScanResult(result, exitCode, outputFile)
}

private void handleScanResult(Map result, int exitCode, String outputFile) {
    def criticalCount = result.Results.sum { it.Vulnerabilities.count { it.Severity == 'CRITICAL' } }
    
    if (criticalCount > 0) {
        sh "aws s3 cp ${outputFile} s3://my-bucket/trivy-reports/"
        error "Trivy scan failed: ${criticalCount} critical vulnerabilities found"
    } else if (exitCode != 0) {
        error "Trivy scan failed with exit code ${exitCode}"
    }
    sh "aws s3 cp ${outputFile} s3://my-bucket/trivy-reports/"
}

private validateInput(){
    if(!config.registry){
        error "Trivy scan failed: 'registry' parameter is required"
    }
    if(!config.repository){
        error "Trivy scan failed: 'repository' parameter is required"
    }
    if(!config.tag){
        error "Trivy scan failed: 'tag' parameter is required"
    }
    if(!config.registryType){
        error "Trivy scan failed: 'registryType' parameter is required"
    }
    if(config.registryType == 'ecr' && (!config.awsRegion || !config.awsAccountId)){
        error "Trivy scan failed: 'awsRegion' and 'awsAccountId' parameters are required for ECR registry"
    }
}

private void pullImage(String imageName){
    if(config.registryType == 'ecr'){
        sh "aws ecr get-login-password --region ${config.awsRegion} | skopeo login --username AWS --password-stdin ${config.awsAccountId}.dkr.ecr.${config.awsRegion}.amazonaws.com"
        sh "skopeo copy docker://${config.awsAccountId}.dkr.ecr.${config.awsRegion}.amazonaws.com/${imageName} docker-archive:${imageName}.tar"
    }
}
