// setup for jest unit test
import Vue from 'vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)
Vue.prototype.$axios = axios

import VueFlashMessage from 'vue-flash-message';
Vue.use(VueFlashMessage);

const dotenv = require('dotenv');
dotenv.config();

Vue.prototype.$lark_url = process.env.VUE_APP_ROOT_API
