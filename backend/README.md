# simpleChat API
> built with [cgapp](https://github.com/create-go-app/cli)

Monolithic API

# Structure
```
.
├── app
│   ├── controllers
│   ├── models
│   └── queries
├── docker
├── docs
├── main.go
├── pkg
│   ├── configs
│   ├── middleware
│   ├── repository
│   ├── routes
│   └── utils
├── platform
│   ├── cache
│   ├── database
│   └── migrations
└── rest
    ├── auth.http
    └── main.http
```
## ./app
비지니스 로직만을 다루는 폴더 입니다.
어떤 데이터베이스 드라이버를 쓰는지, cache 전략을 갖고 있는지 혹은 third-party 등을 다루지 않습니다.
- `./app/controllers` router에서 사용되는 함수 단위의 contoller를 정의합니다. Fiber의 Handler에 해당합니다.
- `./app/models` 비지니스 모델 및 메소드를 정의 합니다. request 및, response에 해당합니다.

## ./docs
API 문서를 포함합니다. swager가 자동으로 생성합니다.

## ./pkg

프로젝트에 특정지어지는 기능들을 포함합니다. configs, middleware, routes, utils와 같이 비지니스에 사용되는 코드들이 해당합니다.

- `./pkg/configs` configuration가 정의됩니다. i.e. readTimeout
- `./pkg/middleware` middleware에 해당합니다. i.e. logger, cors
- `./pkg/repository` const 값이 정의됩니다. i.e. enum values
- `./pkg/routes` handler들을 routing합니다.
- `./pkg/utils`  utility를 포합합니다. i.e. server starter, error checker, etc

## .platform
platform level의 로직을 포함합니다. 실제로 프로젝트를 서비스하기 위해 필요한 기반 로직을 다룹니다. database나 cache등이 있습니다.

- `./platform/database` database의 connection를 관리합니다.
- `./platform/migrations` migrations 파일을 관리합니다.
- `./platform/cache` cache connection을 관리합니다.

# Commands
## Run Project
```
$ make compose.up
```
## Make migrations
```
$ migrate create -ext sql -dir platform/migrations create_users_table
```

# Notes
## WebSocket Proxy
reverse proxy를 사용한다면 socket 통신을 위해 설정을 해줘야 한다.
```
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "Upgrade";
```
- http1.1 명시
  - websocket으로 upgrade는 http1.1에서만 된다. 관련 이슈: [WebSocket over HTTP2](https://github.com/websockets/ws/issues/1458)
- upgrade 헤더를 명시해줘야 한다.
  - ws 요청은 Upgrade 헤더를 사용한다. Upgrade hop-by-hop 헤더로 end-to-end 헤더가 아니기때문에 중간에 케시나 프록시에의해 전달이 안되기도 한다.
- 연결을 닫지않고 연결 상태로 유지하도록 해야한다.
![websocket request](https://user-images.githubusercontent.com/38058085/149462229-eb6c95cf-8f10-41aa-87fd-9ad53aeea0e3.png)

## User table 생성 불가
user는 예약어기 때문에 user이름으로 table을 생성할 수 없다.
따라서 schema를 생성하여 [schema안에서 table을 생성](https://stackoverflow.com/a/61137257/12364975)해준다.
postgresql에서 schema는 namespace와 같다.

## Integration Test:Redis
api 테스트 작성중 redis 연결을 mock해야 하는 문제 발생
- 해결
  - 함수를 overwrite를 할 수 없기 때문에 임시로 띄운 redis를 사용하는 방법으로 해결
  - [miniredis](https://github.com/alicebob/miniredis)사용하여 unit test용 redis 실행
- 개선
  - redis interface를 만들어서 유연하게 함수들이 유연하게 mock 될수 있도록 리팩토링

## Integration Test:SQL
api 테스트중 db에 접근을 mock해야 하는 문제 발생
- 해결
  - [go-sqlmock](https://github.com/DATA-DOG/go-sqlmock)를 사용하여 query를 mock하여 해결
- 개선
  - redis 처럼 테스트코드에서 redis를 띄우는것이 아닌 database가 실행 되어있어야 하는문제
  - [dockertest](https://github.com/ory/dockertest)를 사용하면 해결 될 것 같다.


# Tips
## database
### psql
```
\l - 전체 데이터베이스 조회
\c - 데이터베이스 연결
\dn - 전체 schema 조회
\dt - public schema의 table 조회
\dt schema1.* - schema1의 table 조회
```
### database namaing convention
- table 이름
  - 소문자
  - 단수

# Reference
<details>
    <summary>내용 보기</summary>

## System Design

- [Building a simple Chat application with WebSockets in Go and Vue.js](https://www.whichdev.com/go-vuejs-chat/)
- [design a chat system](https://systeminterview.com/design-a-chat-system.php)
- [Ace the System Interview— Design a Chat Application](https://towardsdatascience.com/ace-the-system-interview-design-a-chat-application-3f34fd5b85d0)
- [A Microservices-based Chat Backend – System Design](https://mmaresch.com/index.php/2020/01/15/a-microservices-based-chat-backend-system-design/)
- [What I've learned from Signal server source code](https://softwaremill.com/what-ive-learned-from-signal-server-source-code/)
- [실시간 댓글 개발기(part.1) – DAU 60만 Alex 댓글의 실시간 댓글을 위한 이벤트 기반 아키텍처](https://tech.kakao.com/2020/06/08/websocket-part1/)
- [How to Make a Messaging App like WhatsApp, Telegram, Slack (Updated)](https://www.simform.com/blog/how-to-build-messaging-app-whatsapp-telegram-slack/)
- [LINE LIVE 채팅 기능의 기반이 되는 아키텍처
](https://engineering.linecorp.com/ko/blog/the-architecture-behind-chatting-on-line-live/)
- [Making my Socket.io chat app production ready with Vue.js, DynamoDB, CodePipeline, and CodeBuild](https://medium.com/containers-on-aws/making-my-socket-io-chat-app-production-ready-with-vue-js-dynamodb-codepipeline-and-codebuild-e6cd24b4b79e)

## 3rd Party API
- [Twilio](https://www.twilio.com/docs/chat/rest)

## database
### schema
- [Cannot create a database table named 'user' in PostgreSQL](https://stackoverflow.com/questions/22256124/cannot-create-a-database-table-named-user-in-postgresql)
- [PostgreSQL 데이터베이스 & 스키마](https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=seuis398&logNo=70097173659)
- [What is a PostgreSQL schema](What is a PostgreSQL schema)

### naming convention
- [How I Write SQL, Part 1: Naming Conventions](https://launchbylunch.com/posts/2014/Feb/16/sql-naming-conventions/)
- [Table Naming Dilemma: Singular vs. Plural Names [closed]](https://stackoverflow.com/questions/338156/table-naming-dilemma-singular-vs-plural-names)

## Tests
- [Golang의 test 이야기](https://sang5c.tistory.com/60)
- [Understanding Unit and Integration Testing in Golang.](https://medium.com/@victorsteven/understanding-unit-and-integrationtesting-in-golang-ba60becb778d)
### SQL Test
- [Unit Test (SQL) in Golang](https://medium.com/easyread/unit-test-sql-in-golang-5af19075e68e))
- [Understanding Unit and Integration Testing in Golang.](https://medium.com/@victorsteven/understanding-unit-and-integrationtesting-in-golang-ba60becb778d)
### Redis Test
- [Unit Test (Redis) in Golang](https://medium.com/easyread/unit-test-redis-in-golang-c22b5589ea37)
- [[golang] go-redis, redis-mock 사용법 및 예제(suite 사용법)](https://frozenpond.tistory.com/164)

</details>
