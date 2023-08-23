#!groovy
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
        GIT_PROJECT_ADDR="http://192.168.1.199:3000/entdiy.xyz/somersault-cloud-ui.git"
    }

    stages {
        stage("git checkout") {
            steps {
                git (url: "${env.GIT_PROJECT_ADDR}",
                     //branch: "${BRANCH_COMMIT}",
                     credentialsId: "git_secret_for_jenkins")
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
                sh "docker pull openresty/openresty:1.21.4.1-0-bullseye-fat"

                sh "docker build . -t somersault-cloud/openresty:1.0.0-snapshot"
                sh "docker tag somersault-cloud/openresty:1.0.0-snapshot ${params.image_push_registry}/somersault-cloud/openresty:1.0.0-snapshot"
                sh "docker push ${params.image_push_registry}/somersault-cloud/openresty:1.0.0-snapshot"
            }
        }

        stage ("trigger dev server deploy update") {
            steps{
                build wait: false, job: "somersault-cloud-devops",
                      parameters: [
                           booleanParam(name: "microservice_deploy", value: false),
                           booleanParam(name: "frontend_deploy", value: true)
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
                           booleanParam(name: "microservice_deploy", value: false),
                           booleanParam(name: "frontend_deploy", value: true),
                           string(name: 'ansible_hosts', value: 'hosts-multiple')
                      ]
            }
        }
    }
}
