# simpleChat CI/CD

# Execute
- staging 브랜치에 push
- jenkins 실행 위해서는 commit message에 `run jenkins` 적어야한다.

# Notes
## jenkins sudo 권한 부여
docker build permission 에러 발생
```shell
$ go build github.com/shinjam/simpleChat: copying /tmp/go-build4290285243/b001/exe/a.out: open simpleChat: permission denied
```
- docker 그룹에 jenkins 유저 추가
```shell
$ sudo usermod -aG docker jenkins
```

## Trigger Jenkins with GitHub Action
테라폼 프로비저닝이 되고,기본적인 lint 검사 후 jenkins가 trigger 될수 있는 방법 모색
1. [jenkiins-action](https://github.com/appleboy/jenkins-action) 사용
action을 사용하면 간단하게 구현이 가능하지만 parameterized build가 불가능하다.
2. curl로 webhook으로 trigger
  ```shell
  $ curl -X POST -u "user:젠킨스토큰" "http://myjenkins/path/to/my/job/buildWithParameters?GERRIT_REFNAME=feature/retry&goal=package"
  ```
  - plugin 설치: [Generic Webhook Trigger Plugin](https://plugins.jenkins.io/generic-webhook-trigger/)
  - jenkins token 생성

3. terraform job에대한 dependency를 위해 needs 키워드 사용
4. 프로비저닝과 별개로 jenkins를 실행시키기위해 commit message 조건 추가
  - workflow별로 dependency를 주고 싶어 workflow_run이라는 것을 찾았지만 [default 브랜치에서만 사용가능](https://github.community/t/on-workflow-run-does-not-work-for-me/128833)


<details>
    <summary>내용 보기</summary>

- [GitHub Action으로 Jenkins에 요청보내기](https://velog.io/@znftm97/GitHub-Action으로-Jenkins에-요청보내기)
- [젠킨스 사용하여 자동 배포환경 만들기!](https://zuminternet.github.io/JENKINS-BUILD/)
- [[Jenkins] curl로 파라미터 주면서 빌드 시작하는 방법](https://velog.io/@owljoa/190731-임시)
- [How to put conditional job in need of another job in Github Action](https://stackoverflow.com/a/68952093/12364975)
- [Jenkins Generic Webhook Trigger를 이용한 GitHub branch별 push event WebHook 설정](https://freedeveloper.tistory.com/464)


</details>


# Tips
## Linux commands
- `getent group docker`: docker그룹의 user 확인
- `id`: 현재 유저 정보
- `chwon -R user:group dir`: dir를 recursive하게 user:group 변경
- `sudo usermod -aG docker $USER`: docker 그룹에 현재 유저 추가
- `gpasswd -d user2 sshgroup`: sshgroup에서 user2제거
- `su --shell /bin/bash ks1`: ks1 유저로 새로운 shell 실행
- `yum list installed jenkins`: jenkins 설치 확인
