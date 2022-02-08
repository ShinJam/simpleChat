## v1.1.0 (2022-02-08)

### Fix

- comment out go releaser gh action
- golangcli gh action
- edit staging action to trigger to push staging
- fabfile
- **backend**: fix error response from errSaveToRedis
- **jenkins**: update target_svr
- **terraform**: add sg's ingress and egress config
- solve gocritic and lint
- typo container name
- **views**: message sender name to email
- **docker**: soelve nginx websocket error
- **frontend**: use state.currentUser instead state.user
- **app/queries**: restore models.users to repository.users when get all users
- **platform/migrations**: fix data type tinyint to smallint
- **pkg/utils**: add redis connection

### Refactor

- **terraform**: add jenkins dir to templates
- **terraform**: add jenkins dir to templates
- **terraform**: add jenkins dir to templates
- move make prune from backend dir to project dir
- **terraform**: change t2.micro to t2.nano
- **terraform**: modify local to remote
- **terraform**: add environment variable
- **terraform**: modify terraform action
- **terraform**: move deployment to terraform
- delete terraform ci
- git ignore ide likes
- change migrations to use schema and some others
- **views**: make sure only one client of the user counts
- **views**: refacotr Home, Login views to use vue3 features
- **docker**: fix a problem with a WebSocket request to a server
- **frontend**: make login singup redirection using localstorage
- **backend/controllers**: make user_role when signing up

### Feat

- add Navigation Guard
- **views**: change serverUrl to use location.host
- implement private chat
- implement pub/sub
- add user queries
- make room model and migrations, queires
- implement chat room
- implement 1to1 chat feature
- **frontend**: implement user store using vuex
- **frontend**: implement signin, signup ui with axios
- **frontend**: init frontend project with vite
- **pkg/routes**: add not found route
- implement private apis that have to use jwt
- **implement-user-apis**: signin, singout, signup
- **platform/cache**: implement redis connection
- **utils**: make jwt related uitls
- **app/models**: make auth and token model
- **app/queries**: make user queries
- **platform/migrations**: make user migrations
- **app/models**: make user model
- implement gracefully shutdown
- scaffold project with fiber
