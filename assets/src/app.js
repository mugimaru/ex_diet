import Vue from 'vue';

import Router from 'vue-router';
Vue.use(Router);

import BootstrapVue from 'bootstrap-vue';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
Vue.use(BootstrapVue);

import App from './App.vue';
import router from './config/router.js';

import {apolloProvider, VueApollo} from './config/apollo.js';
Vue.use(VueApollo);

new Vue({
  el: '#app',
  router,
  data: {
    userEmail: localStorage.getItem("userEmail")
  },
  provide: apolloProvider.provide(),
  render: h => h(App)
});
