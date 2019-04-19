import Vue from 'vue'
import App from './App.vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)
Vue.prototype.$axios = axios

Vue.config.productionTip = false
Vue.config.errorHandler = (err) => {
    alert(err.message)
}

new Vue({
  render: h => h(App)
}).$mount('#app')
