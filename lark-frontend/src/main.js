import Vue from 'vue'
import App from './App.vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)
Vue.prototype.$axios = axios

import mixin from '@/assets/scripts/app'
import router from '@/router/routes'

Vue.config.productionTip = false
Vue.config.errorHandler = (err) => {
    alert(err.message)
}

Vue.prototype.$status = response => {
  if (response.status >= 200 && response.status < 300) {
    return Promise.resolve(response)
  }
  return Promise.reject(new Error(response.statusText))
}

Vue.prototype.$lark_url = process.env.VUE_APP_ROOT_API
Vue.prototype.$json = response => response.json()

Vue.prototype.$cors_headers = {
  mode: 'cors',
  headers: { 'Content-Type': 'application/json' } }

new Vue({
  mixins: [mixin],
  router,
  render: h => h(App)
}).$mount('#app')
