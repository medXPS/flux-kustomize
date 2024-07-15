pipeline {
    agent any

    environment {
        registryName = '20.61.52.27:8081/repository/docker-repository' // Nexus repository URL
        registryCredential = 'nexus-registry' // Credential ID for Nexus (configured with username/password)
        dockerImage = ''
        imageTag = "latest-${BUILD_NUMBER}" // Default tag with build number
        gitRepoURL = 'https://github.com/medXPS/flux-kustomize.git' // Code Repository
        gitRepoDir = 'gateway-service' // Provided directory name of your base code 
        dockerfilePath = 'microservices/gateway-service/src/Dockerfile' // Dockerfile path
        k8sManifestsDir = 'k8s/gateway-service/base/deployment.yaml' // Kubernetes deployment file (contains image tag)
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    deleteDir()
                    checkout([$class: 'GitSCM',
                              branches: [[name: 'main']],
                              doGenerateSubmoduleConfigurations: false,
                              extensions: [[$class: 'CleanBeforeCheckout'], [$class: 'RelativeTargetDirectory', relativeTargetDir: gitRepoDir]],
                              submoduleCfg: [],
                              userRemoteConfigs: [[url: gitRepoURL]]])
                }
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    dir(gitRepoDir) {
                        imageTag = "latest-${BUILD_NUMBER}"
                        dockerImage = docker.build(registryName, "-f ${dockerfilePath} . --tag ${imageTag}")
                    }
                }
            }
        }

        stage('Push Image to Nexus Repository') {
            steps {
                script {
                    docker.withRegistry("http://${registryName}", registryCredential) {
                        dockerImage.push("${imageTag}")
                    }
                }
            }
        }

        stage('Update Manifests and Push to Git') {
            steps {
                script {
                    def cloneDir = 'GitOps'

                    if (!fileExists(cloneDir)) {
                        sh "git clone https://github.com/medXPS/flux-kustomize.git ${cloneDir}"
                    }

                    def manifestsDir = "${cloneDir}/${k8sManifestsDir}"

                    def newImageLine = "image: ${registryName}:${imageTag}"

                    sh "sed -i 's|image: sk09devops/flux-kustomize:latest.*|${newImageLine}|' ${manifestsDir}"

                    withCredentials([usernamePassword(credentialsId: 'GIT', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        dir(cloneDir) {
                            sh "git config user.email mohamedammaha2020@gmail.com" 
                            sh "git config user.name medXPS" 
                            sh "git add ."
                            sh "git commit -m 'Update image tag in Kubernetes manifests'"
                            sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/medXPS/flux-kustomize.git HEAD:main"
                        }
                    }
                }
            }
        }
    }
}
