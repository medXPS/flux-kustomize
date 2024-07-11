pipeline {
    agent any

    environment {
        registryName = 'sk09devops/flux-kustomize' // Provided Docker Hub repository name
        registryCredential = 'DOCKERHUB' // Provided credential name
        dockerImage = ''
        imageTag = "1.0.0.-${BUILD_NUMBER}" // Default tag with build number
        gitRepoURL = 'https://github.com/medXPS/flux-kustomize.git' // Code Repository
        gitRepoDir = 'gateway-service' // Provided directory name of your base code 
        dockerfilePath = 'microservices/gateway-service/src/Dockerfile' // Dockerfile path
        k8sManifestsDir = 'k8s/gateway-service/base/deployment.yaml' // Kubernetes deployement file(contains image tag)
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
                        
                        imageTag = "1.0.0.-${BUILD_NUMBER}"
                        dockerImage = docker.build(registryName, "-f ${dockerfilePath} . --tag ${imageTag}")
                    }
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    docker.withRegistry("https://registry.hub.docker.com", registryCredential) {
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
                        sh "git clone https://github.com/DevOpsTestOrgAi/GitOps.git ${cloneDir}"
                    }

                    def manifestsDir = "${cloneDir}/${k8sManifestsDir}"

                    def newImageLine = "image: ${registryName}:${imageTag}"

                    sh "sed -i 's|image: sk09devops/flux-kustomize:1.0.0..*|${newImageLine}|' ${manifestsDir}"

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
        //   stage('Push Update status to Microsoft Teams') {
        //     steps {
        //         //Push notifications to Microsoft Teams
        //     }
        // }
    }
}