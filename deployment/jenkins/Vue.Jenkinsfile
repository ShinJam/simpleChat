pipeline {
  agent any

  parameters {
    booleanParam(name : 'DEPLOY_WORKLOAD', defaultValue : true, description : 'DEPLOY_WORKLOAD')
    booleanParam(name : 'NPM_INSTALL', defaultValue : true, description : 'NPM_INSTALL')
    booleanParam(name : 'NPM_BUILD', defaultValue : true, description : 'NPM_BUILD')

    string(name: 'AWS_ACCOUNT_ID', defaultValue: '559121217486', description: 'AWS_ACCOUNT_ID')
    // S3
    string(name: 'S3_BUCKET_NAME', defaultValue: 'kuve-20220207055615300800000001', description: 'S3_BUCKET_NAME')
  }
  environment {
    REGION = 'ap-northeast-2'
    ECR_REPOSITORY_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com"
    BUCKET = "${params.S3_BUCKET_NAME}"
  }

  stages {
    stage('============ NPM Install ============') {
      when { expression { return params.NPM_INSTALL } }
      steps {
        dir("${env.WORKSPACE}/frontend") {
          sh 'sudo npm install'
        }
      }
    }
    stage('============ NPM run build ============') {
      when { expression { return params.NPM_BUILD } }
      steps {
        dir("${env.WORKSPACE}/frontend") {
          sh '''
            aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}; \
            sh exportEnvs.sh \
            sudo npm run build
          '''
        }
      }
    }
    stage('============ sync vue bucket ============') {
      when { expression { return params.DEPLOY_WORKLOAD } }
      steps {
        dir("${env.WORKSPACE}/frontend") {
          sh 'aws s3 sync ./dist s3://${BUCKET}'
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
