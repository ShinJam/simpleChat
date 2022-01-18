# simpleChat

<img src="https://img.shields.io/badge/Go-1.17+-00ADD8?style=for-the-badge&logo=go" alt="go version" />&nbsp;<img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge&logo=none" alt="license" />

# Features
- Authentication
  - JWT
- Chat
  - 1:1
  - n:n
## TL;DR
### Frontend
- Vue3를 사용한 UI 구성
- Vuex를 사용하여 상태관리
- bootstrap5를 사용한 style
- Websocket으로 socket 통신

### Backend
- Go Fiber로 API 구현
- postgres로 유저, 채팅 정보 저장
- [golang-migrate/migrate](https://github.com/golang-migrate/migrate)로 migration 관리
- [sqlx](https://github.com/jmoiron/sqlx)를 사용하여 query 요청
- redis로 pub/sub 구현
# ⚡️ Goal of project

- 고가용성 인프라 구축을 위한 간단한 Application 개발
- Messaging Architecture 구축(i.e. Redis, Kafka, RabbitMQ)

# Solutions
## k8s
부하 분산을 위해 로드벨런서를 사용하고 그에 따른 서버 스케일 아웃을 및 오케스트레이션을 위한 kubernetes 사용
## Websocket
실시간 양방향 채팅을 위해 socket 통신을 구현한다. webRTC를 사용할 수 도 있지만 최소한의 개발을 위해 자료가 많고 client 개발에 대한 이해도가 낮기 때문에 socket으로 선택
## Redis
그룹 채팅을 귀현하기 위해서는 그룹에 있는 모든 사람들에게 메세지를 전달해야 한다. 따라서 pub/sub을 할수 있고 가장 간단하고 이해가 편한 redis를 사용한다. kafka, RabbitMQ 등 다양한 메세징 솔루션들이 있다. 정확한 차이는 추후 더 알아봐야 한다.

# Designs
## UI Flow Chart
![UI Flow Chart](https://user-images.githubusercontent.com/38058085/149257784-bf663846-cade-4c85-8eb0-5e0946af7f8c.png)
- 단순하게 유저 인증관련 화면과 채팅에 접속할 수 있는 화면으로 구성
## Message Flow Chart
![Message Flow Chart](https://user-images.githubusercontent.com/38058085/149257051-d4461d44-9010-4135-b935-8653c4336444.png)

- Monolithic으로 구현 되었기 때문에 하나의 컨테이너안에 ws와 http 요청을 같이 받는다.
- User가 chat room에 입장하면 해당 room을 subscribe 하게 된다.
- 메세지를 보내면 redis에서 publish 하게 되면서 채팅방에 메세지가 보이게 된다.

# 📦 Built With
- go 1.17+
- [Fiber v2](https://github.com/gofiber/fiber)
- postgresql 14.1
- redis 6.2
- vue 3.x.x

# Todo
<details>
    <summary>내용 보기</summary>

- [ ] MSA
- [ ] Unit Test
- [ ] Load/Stress/Performance Test
- [ ] Coverage
- [ ] gosec
- [ ] goreport
- [ ] Add Change Log
- [ ] CI/CD
- [ ] Mornitoring
- [ ] Pub/Sub
- [ ] k8s
- [ ] NoSQL
- [ ] Snowflake
- [ ] Terraform

</details>


# Reference
<details>
    <summary>내용 보기</summary>

## Planning
- [인앱 채팅 기획하기](https://brunch.co.kr/@eunbeecho/34)

</details>
