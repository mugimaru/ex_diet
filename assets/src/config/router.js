import Router from 'vue-router'
import App from '../App.vue'
import Index from '../components/Index.vue'
import AppLogin from '../components/AppLogin.vue'

export default new Router({
  routes: [
    { path: '/',component: Index },
    { path: '/login', component: AppLogin }
  ]
})
