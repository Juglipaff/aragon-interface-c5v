import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import ProgressBar from 'vuejs-progress-bar'

import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { faCog } from '@fortawesome/free-solid-svg-icons'

library.add(faCog)
Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.use(ProgressBar)
Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
