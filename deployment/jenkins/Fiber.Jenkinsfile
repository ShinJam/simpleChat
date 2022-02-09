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
    stage('============ Update kubeconfig ============') {
      when {
        expression {
          return params.BUILD_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/deployment") {
          sh 'aws eks update-kubeconfig --region ap-northeast-2 --name kuve-cluster --alias kuve-cluster'
        }
      }
    }
    stage('============ Apply secrets and Configmap ============') {
      when {
        expression {
          return params.PUSH_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/deployment") {
          sh'''
              kubectl apply -f k8s/backend-secret-v1.yaml; \
              kubectl apply -f k8s/backend-configmap-v1.yaml
            '''
        }
      }
    }
    stage('============ Apply deployment ============') {
      when {
        expression {
          return params.PUSH_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/deployment") {
          sh'''
              kubectl apply -f k8s/backend-deploy.yaml
            '''
        }
      }
    }
    stage('============ Apply service ============') {
      when {
        expression {
          return params.PUSH_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/deployment") {
          sh'''
              kubectl apply -f k8s/backend-service.yaml
            '''
        }
      }
    }
    stage('============ Apply HPA ============') {
      when {
        expression {
          return params.PUSH_DOCKER_IMAGE
        }
      }
      steps {
        dir("${env.WORKSPACE}/deployment") {
          sh'''
              kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml; \
              kubectl apply -f k8s/backend-hpa.yaml
            '''
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
