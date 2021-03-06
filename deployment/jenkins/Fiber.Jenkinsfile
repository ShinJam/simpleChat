pipeline {
  agent any

  parameters {
    booleanParam(name: 'BUILD_DOCKER_IMAGE', defaultValue: true, description: 'BUILD_DOCKER_IMAGE')
    booleanParam(name: 'PUSH_DOCKER_IMAGE', defaultValue: true, description: 'PUSH_DOCKER_IMAGE')
    booleanParam(name : 'DEPLOY_WORKLOAD', defaultValue : true, description : 'DEPLOY_WORKLOAD')

    // CI
    string(name: 'AWS_ACCOUNT_ID', defaultValue: '559121217486', description: 'AWS_ACCOUNT_ID')
    string(name : 'DOCKER_IMAGE_NAME', defaultValue : 'fiber', description : 'DOCKER_IMAGE_NAME')
    string(name : 'DOCKER_TAG', defaultValue : 'latest', description : 'DOCKER_TAG')

    // CD
    string(name : 'TARGET_SVR_USER', defaultValue : 'ec2-user', description : 'TARGET_SVR_USER')
    string(name : 'TARGET_SVR_PATH', defaultValue : '/home/ec2-user/', description : 'TARGET_SVR_PATH')
    string(name : 'TARGET_SVR', defaultValue : '10.0.3.156', description : 'TARGET_SVR')
  }
  environment {
    REGION = 'ap-northeast-2'
    ECR_REPOSITORY_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com"
    ECR_DOCKER_IMAGE = "${ECR_REPOSITORY_URI}/${params.DOCKER_IMAGE_NAME}"
    ECR_DOCKER_TAG = "${params.DOCKER_TAG}"
  }

  stages {
    stage('============ Build Docker Image ============') {
      when {
        expression {
          return params.BUILD_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/backend") {
          sh 'docker build -t ${ECR_DOCKER_IMAGE}:${ECR_DOCKER_TAG} -f docker/Dockerfile.fiber .'
        }
      }
    }
    stage('============ Push Docker Image ============') {
      when {
        expression {
          return params.PUSH_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/backend") {
          sh'''
              aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}
              docker push ${ECR_DOCKER_IMAGE}:${ECR_DOCKER_TAG}
            '''
        }
      }
    }
    stage('============ Deploy workload ============') {
      when { expression { return params.DEPLOY_WORKLOAD } }
      steps {
          sshagent (credentials: ['aws_ec2_user_ssh']) {
              sh """#!/bin/bash
                  scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                      ${env.WORKSPACE}/backend/docker/staging.yml \
                      ${env.WORKSPACE}/backend/exportEnvs.sh \
                      ${params.TARGET_SVR_USER}@${params.TARGET_SVR}:${params.TARGET_SVR_PATH};

                  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                      ${params.TARGET_SVR_USER}@${params.TARGET_SVR} \
                      'aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}; \
                       sh exportEnvs.sh \
                       docker-compose -f staging.yml down; \
                       IMAGE=${ECR_DOCKER_IMAGE} TAG=${ECR_DOCKER_TAG} docker-compose -f staging.yml up -d';
              """
          }
      }
    }
  }
    post {
    success {
      slackSend(
        channel: "#jenkins",
        color: "good",
        message: "[Successful] Job:${env.JOB_NAME}, Build num:#${env.BUILD_NUMBER} (<${env.RUN_DISPLAY_URL}|open job detail>)"
      )
    }
    failure {
      slackSend(
        channel: "#jenkins",
        color: "danger",
        message: "[Failed] Job:${env.JOB_NAME}, Build num:#${env.BUILD_NUMBER} @channel (<${env.RUN_DISPLAY_URL}|open job detail>)"
      )
    }
  }
}

// post {
//   success {
//     slackSend(
//       channel: '#jenkins',
//       color: 'good',
//       message: "✅ Job:${env.JOB_NAME}, Build num:#${env.BUILD_NUMBER} (<${env.RUN_DISPLAY_URL}|open job detail>)"
//     )
//   }
//   failure {
//     slackSend(
//       channel: '#jenkins',
//       color: 'danger',
//       message: "⛔ Job:${env.JOB_NAME}, Build num:#${env.BUILD_NUMBER} @channel (<${env.RUN_DISPLAY_URL}|open job detail>)"
//     )
//   }
// }
