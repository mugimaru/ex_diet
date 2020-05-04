/* global require */

import Vue from 'vue';

import Router from 'vue-router';

import Vuelidate from 'vuelidate';

import BootstrapVue from 'bootstrap-vue';
import './main.scss';
// import 'bootstrap/dist/css/bootstrap';
// import 'bootstrap-vue/dist/bootstrap-vue.css';

import draggable from 'vuedraggable';
import VueChartkick from 'vue-chartkick';
import VueMoment from 'vue-moment';
import moment from 'moment-timezone';
import App from './App.vue';
import router from './config/router.js';

import { apolloProvider, VueApollo } from './config/apollo.js';

import apolloErrorsView from './components/ApolloErrorsView.vue';

import timedAlert from './components/TimedAlert.vue';

Vue.config.productionTip = false;
Vue.use(Router);
Vue.use(Vuelidate);
Vue.use(BootstrapVue);

import VueLodash from 'vue-lodash'
import lodash from 'lodash'
Vue.use(VueLodash, { lodash: lodash })

Vue.use(VueMoment, { moment });

Vue.use(VueApollo);
Vue.component('apollo-errors-view', apolloErrorsView);
Vue.component('timed-alert', timedAlert);
Vue.component('draggable', draggable);
Vue.use(VueChartkick);

require('open-iconic/font/css/open-iconic-bootstrap.css');

new Vue({
  router,
  data: {
    userEmail: localStorage.getItem('userEmail'),
  },
  apolloProvider: apolloProvider,
  render: (h) => h(App),
}).$mount('#app');
