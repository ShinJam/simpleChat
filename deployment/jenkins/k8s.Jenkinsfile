pipeline {
  agent any

  parameters {
    booleanParam(name: 'BUILD_DOCKER_IMAGE', defaultValue: true, description: 'BUILD_DOCKER_IMAGE')
    booleanParam(name: 'PUSH_DOCKER_IMAGE', defaultValue: true, description: 'PUSH_DOCKER_IMAGE')
    booleanParam(name : 'DEPLOY_WORKLOAD', defaultValue : true, description : 'DEPLOY_WORKLOAD')
    string(name: 'EKS_CLUSTER_NAME', defaultValue: 'kuve-cluster', description: 'EKS_CLUSTER_NAME')

    // CI
    string(name: 'AWS_ACCOUNT_ID', defaultValue: '559121217486', description: 'AWS_ACCOUNT_ID')
    string(name : 'DOCKER_IMAGE_NAME', defaultValue : 'fiber', description : 'DOCKER_IMAGE_NAME')
    string(name : 'DOCKER_TAG', defaultValue : 'latest', description : 'DOCKER_TAG')

  }
  environment {
    REGION = 'ap-northeast-2'
    ECR_REPOSITORY_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com"
    ECR_DOCKER_IMAGE = "${ECR_REPOSITORY_URI}/${params.DOCKER_IMAGE_NAME}"
    ECR_DOCKER_TAG = "${params.DOCKER_TAG}"
    CLUSTER_NAME = "${params.EKS_CLUSTER_NAME}"
  }

  stages {
    stage('============ Get Kube Config ============') {
      when {
        expression {
          return params.BUILD_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/terraform") {
          sh 'aws eks update-kubeconfig --region $REGION --name ${CLUSTER_NAME}'
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
