# Frontend using vue

## Installation and start
reference by: [Vue Router | Building single page applications
](https://www.youtube.com/watch?v=nKg_p89Hzos)
```
$ npm init @vitejs/app
$ npm run dev
```

## Notes
### v-for v-if 동시 사용
v-for로 데이터를 조회하여 v-if조건 사용에 문제가 있었다.
user list에서 현재 접속한 user을 제외하여 랜더링 하고 싶었으나 email이 없다고 undefined 에러가 났다.
```html
<div
  class="col-2 card profile"
  v-for="user in state.users"
  v-if="user.email != state.currentUser.email"
  :key="user.id"
>
```
해결방법으로 여러가지가 있지만 제일 간단한 [computed를 사용](https://stackoverflow.com/a/48934453/12364975)하여 filter된 list를 사용하는 방법으로 해결했다.
```html
<div
  class="col-2 card profile"
  v-for="user in state.usersList"
  :key="user.id"
>

<script>
...
usersList: computed(() => state.users.filter(user => user.email != state.currentUser.email))
...
<script>
```

## ETC
### alis 설정
reference by : [`Vue3 - Vite` project alias src to @ not working](https://stackoverflow.com/questions/66043612/vue3-vite-project-alias-src-to-not-working)
```
// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  }
})
```

### bootstrap
reference by: [BootstrapVue 3](https://cdmoro.github.io/bootstrap-vue-3/getting-started/#bundlers)
```
$ npm i bootstrap bootstrap-vue-3 --save
```

### Auth
reference by: [github.com/SinghDigamber/vue-login-signup-ui](https://github.com/SinghDigamber/vue-login-signup-ui)

### request with axios
```
// https://www.npmjs.com/package/vue-axios
$ npm install --save axios vue-axios
```

### vuex
reference by: [Vue.js JWT Authentication with Vuex and Vue Router](https://www.bezkoder.com/jwt-vue-vuex-authentication/)
```
$ npm install --save vuex@4.0.1
```


# Reference
<details>
    <summary>내용 보기</summary>

## Vue3
- [Vue 3 변경점 정리: 무엇이 바뀌나요?](https://velog.io/@bluestragglr/Vue3-무엇이-바뀌나요)
- [Vue 3 가볍게 훑어보기](https://joshua1988.github.io/web-development/vuejs/vue3-coming/)
- [A Complete Guide to Vue Lifecycle Hooks - with Vue 3 Updates](https://learnvue.co/2020/12/how-to-use-lifecycle-hooks-in-vue3/#what-are-the-vue-lifecycle-hooks)

</details>
