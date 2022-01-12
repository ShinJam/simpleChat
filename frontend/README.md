# Frontend using vue

## Installation and start
reference by: [Vue Router | Building single page applications
](https://www.youtube.com/watch?v=nKg_p89Hzos)
```
$ npm init @vitejs/app
$ npm run dev
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
