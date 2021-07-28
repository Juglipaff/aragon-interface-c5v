import Vue from 'vue'
import VueRouter from 'vue-router'
import Voting from '../views/Voting.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Voting',
    component: Voting
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
