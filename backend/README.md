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
</details>
