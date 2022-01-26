# simpleChat CI/CD


# Tips
## Trigger with GitHub Action
테라폼 프로비저닝이 되고,기본적인 lint 검사 후 jenkins가 trigger 될수 있는 방법 모색
1. [jenkiins-action](https://github.com/appleboy/jenkins-action) 사용
action을 사용하면 간단하게 구현이 가능하지만 parameterized build가 불가능하다.
2. curl로 webhook으로 trigger
  ```shell
  $ curl -X POST -u "user:젠킨스토큰" "http://myjenkins/path/to/my/job/buildWithParameters?GERRIT_REFNAME=feature/retry&goal=package"
  ```
  - plugin 설치: [Generic Webhook Trigger Plugin](https://plugins.jenkins.io/generic-webhook-trigger/)
  - jenkins token 생성


<details>
    <summary>내용 보기</summary>

- [GitHub Action으로 Jenkins에 요청보내기](https://velog.io/@znftm97/GitHub-Action으로-Jenkins에-요청보내기)
- [젠킨스 사용하여 자동 배포환경 만들기!](https://zuminternet.github.io/JENKINS-BUILD/)
- [[Jenkins] curl로 파라미터 주면서 빌드 시작하는 방법](https://velog.io/@owljoa/190731-임시)

</details>
