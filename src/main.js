import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import ProgressBar from 'vuejs-progress-bar'

Vue.use(ProgressBar)
Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
