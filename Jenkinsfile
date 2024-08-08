pipeline {
    agent any

    environment {
        registryBaseURL = 'adria.westeurope.cloudapp.azure.com:5001/adria-docker-repository' // Base Nexus URL with port 5001
        customer = 'abt' // Set this to the specific customer (e.g., abt, cih, bcp, cmd)
        service = 'contrat-service' // Set this to the specific service (e.g., contrat-service, admin-front)
        registryCredential = 'NEXUS' // Credential ID for Nexus (configured with username/password)
        dockerImage = ''
        imageTag = "3.5.0-${BUILD_NUMBER}" // Default tag with build number
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
                        // Build Docker image with correct repository structure
                        dockerImage = docker.build("${registryBaseURL}/${customer}/${service}:${imageTag}", "-f ${dockerfilePath} .")
                    }
                }
            }
        }

        stage('Push Image to Nexus Repository') {
            steps {
                script {
                    docker.withRegistry("https://${registryBaseURL}", registryCredential) {
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
                        sh "git clone ${gitRepoURL} ${cloneDir}"
                    }

                    def manifestsDir = "${cloneDir}/${k8sManifestsDir}"
                    def newImageLine = "image: ${registryBaseURL}/${customer}/${service}:${imageTag}"

                    sh "sed -i 's|image: .*/.*/.*:.*|${newImageLine}|' ${manifestsDir}"

                    withCredentials([usernamePassword(credentialsId: 'GIT', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        dir(cloneDir) {
                            sh "git config user.email 'mohamedammaha2020@gmail.com'" 
                            sh "git config user.name 'medXPS'" 
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
