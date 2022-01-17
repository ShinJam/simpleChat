import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import store from '@/store/index';

const routes = [
  {
    path: '/',
    redirect: '/home'
  },
  {
    path: '/home',
    name: 'Home',
    component: Home,
    beforeEnter: (to, from, next) => {
      console.log(store.state.auth.user)
      if (store.state.auth.user) {
        next()
      } else {
        next("login")
      }
    },
  },
  {
    path: '/signup',
    name: 'signup',
    component: () => import('@/views/Signup.vue')
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/Login.vue')
  },

]

const router = createRouter({
  // history: createWebHistory(process.env.BASE_URL),
  history: createWebHistory("/"),
  routes
})


export default router
