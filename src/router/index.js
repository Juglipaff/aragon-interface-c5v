import Vue from 'vue'
import VueRouter from 'vue-router'
import Voting from '../views/Voting.vue'
import Tokens from '../views/Tokens.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Voting',
    component: Voting
  },
  {
    path: '/tokens',
    name: 'Tokens',
    component: Tokens
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
