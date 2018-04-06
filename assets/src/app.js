import Vue from 'vue';

import Router from 'vue-router';
Vue.use(Router);

import Vuelidate from 'vuelidate';
Vue.use(Vuelidate);

import BootstrapVue from 'bootstrap-vue';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
Vue.use(BootstrapVue);

import VueLodash from 'vue-lodash';
Vue.use(VueLodash);

import App from './App.vue';
import router from './config/router.js';

Vue.use(require('vue-moment'));

import {apolloProvider, VueApollo} from './config/apollo.js';
Vue.use(VueApollo);

import apolloErrorsView from './components/ApolloErrorsView.vue';
Vue.component('apollo-errors-view', apolloErrorsView);

import timedAlert from './components/TimedAlert.vue';
Vue.component('timed-alert', timedAlert);

new Vue({
  el: '#app',
  router,
  data: {
    userEmail: localStorage.getItem("userEmail")
  },
  provide: apolloProvider.provide(),
  render: h => h(App)
});
