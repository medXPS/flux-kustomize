pipeline {
    agent any

    environment {
        registryBaseURL = 'adria.westeurope.cloudapp.azure.com:5001'
        registryCredential = 'NEXUS' // Credential ID for Nexus (configured with username/password)
        customer = 'abt' // This could be dynamically set based on the pipeline or input parameters
        imageName = 'contrat-service'
        imageTag = "3.5.0-${BUILD_NUMBER}" // Default tag with build number
        fullImageName = "${registryBaseURL}/${customer}/${imageName}:${imageTag}"
        gitRepoURL = 'https://github.com/medXPS/flux-kustomize.git' // Code Repository
        gitRepoDir = 'gateway-service' // Directory of the code
        dockerfilePath = 'microservices/gateway-service/src/Dockerfile' // Dockerfile path
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
                        docker.build("${fullImageName}", "-f ${dockerfilePath} .")
                    }
                }
            }
        }

        stage('Push Image to Nexus Repository') {
            steps {
                script {
                    docker.withRegistry("https://${registryBaseURL}", registryCredential) {
                        docker.image(fullImageName).push()
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
                    def newImageLine = "image: ${fullImageName}"

                    sh "sed -i 's|image: .*/gateway-service:.*|${newImageLine}|' ${manifestsDir}"

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
