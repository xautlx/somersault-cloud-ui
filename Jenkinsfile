#!groovy

def _REVISION_TAG

pipeline {

    agent any

     parameters {

           booleanParam name:"admin_build",
                        defaultValue: true,
                        description:"是否Admin PC应用构建"

           booleanParam name:"h5_build",
                        defaultValue: true,
                        description:"是否H5应用构建"

           gitParameter name: "BRANCH_COMMIT",
                        branchFilter: "origin/(.*)",
                        defaultValue: "master",
                        selectedValue: "DEFAULT",
                        description: "代码的分支",
                        type: "PT_BRANCH_TAG",
                        sortMode: "DESCENDING_SMART",
                        listSize: "5"

           string  name: "image_push_registry",
                   description: "构建镜像推送私服地址",
                   defaultValue: "192.168.1.199:5000"

           string  name: "image_push_user",
                   description: "构建镜像推送私服账号",
                   defaultValue: "docker"

           password name: "image_push_password",
                   description: "构建镜像推送私服密码",
                   defaultValue: "RepoP@ssword4Docker"

           booleanParam name:"hosts_multiple_update",
                        defaultValue: false,
                        description:"默认开发主机更新部署以外是否测试集群环境更新？"
     }


    environment {
        GIT_PROJECT_ADDR="http://192.168.1.199:3000/entdiy/somersault-cloud-ui.git"
    }

    stages {
        stage("git checkout") {
            steps {
                git (url: "${env.GIT_PROJECT_ADDR}",
                     branch: "${BRANCH_COMMIT}",
                     credentialsId: "git_secret_for_jenkins")

                // 显示变量列表信息，便于按需取值
                sh "printenv"

                script {
                    // 默认采用简化定义形式，便于重复开发调试
                    // 可添加提交ID，便于代码追溯定义： _REVISION_TAG = "${BRANCH_COMMIT}-${GIT_COMMIT}"
                    // 可进一步添加时间戳信息便于直观看出代码提交或构建日期时间信息
                    _REVISION_TAG = "${BRANCH_COMMIT}"
                    echo _REVISION_TAG
                }
            }
        }

        stage ("build Admin PC") {
            when{
                equals actual: "${params.admin_build}" ,expected:"true"
            }
            steps{
                sh "yarn --cwd somersault-cloud-ui-admin install"
                sh "yarn --cwd somersault-cloud-ui-admin build:prod"
            }
        }

        stage ("build APP H5") {
            when{
                equals actual: "${params.h5_build}" ,expected:"true"
            }
            steps{
                sh "npm install --g cross-env"
                sh "yarn --cwd somersault-cloud-ui-app install"
                sh "yarn --cwd somersault-cloud-ui-app build:h5"
            }
        }

        stage ("docker registry login") {
            when{
                not {
                   equals actual: "${params.image_push_user}" ,expected:""
                }
            }
            steps{
                sh "docker login -u ${params.image_push_user} -p ${params.image_push_password} ${params.image_push_registry}"
            }
        }

        stage ("docker image") {
            steps{
                //已知Dockerfile中引用镜像偶尔会出现403异常，通过提前pull镜像规避此问题
                //sh "docker pull --platform linux/amd64 openresty/openresty:1.21.4.1-0-bullseye-fat"
                //sh "docker pull --platform linux/arm64 openresty/openresty:1.21.4.1-0-bullseye-fat"

                // https://docs.docker.com/build/building/multi-platform/#qemu
                sh "docker run --privileged --rm tonistiigi/binfmt --install all"
                //sh returnStatus: true, script: "docker buildx rm march_container"
                // https://github.com/moby/buildkit/blob/master/docs/buildkitd.toml.md
                sh "mkdir -p /etc/buildkit"
                sh "echo '[registry.\"${image_push_registry}\"]' > /etc/buildkit/buildkitd.toml"
                sh "echo '  mirrors = [\"${image_push_registry}\"]' >> /etc/buildkit/buildkitd.toml"
                sh "echo '  http = true' >> /etc/buildkit/buildkitd.toml"
                sh "echo '  insecure = true' >> /etc/buildkit/buildkitd.toml"
                // https://docs.docker.com/engine/reference/commandline/buildx_build/
                // https://github.com/docker/buildx#building-multi-platform-images
                sh returnStatus: true, script: "docker buildx create --name=march_container --driver=docker-container --use --driver-opt network=host --config /etc/buildkit/buildkitd.toml"
                sh returnStatus: true, script: "docker buildx inspect --bootstrap"

                sh "docker buildx build --platform linux/amd64,linux/arm64 -t ${params.image_push_registry}/somersault-cloud/openresty:${_REVISION_TAG} . --push"
            }
        }

        stage ("trigger dev server deploy update") {
            steps{
                build wait: false, job: "somersault-cloud-devops",
                      parameters: [
                           string(name: "deploy_target", value: "frontend")
                      ]
            }
        }

        stage ("trigger test servers deploy update") {
            when{
                equals actual: "${params.hosts_multiple_update}" ,expected:"true"
            }
            steps{
                build wait: false, job: "somersault-cloud-devops",
                      parameters: [
                           string(name: "deploy_target", value: "frontend"),
                           string(name: 'ansible_hosts', value: 'hosts-multiple')
                      ]
            }
        }
    }
}
