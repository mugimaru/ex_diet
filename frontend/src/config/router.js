import Router from 'vue-router';
import AppLogin from '../components/AppLogin.vue';
import Ingredients from '../components/ingredients/Index.vue';
import Recipes from '../components/recipes/Index.vue';
import EditRecipe from '../components/recipes/NewOrEdit.vue';
import CalendarDashboard from '../components/calendar/Dashboard.vue';
import Guard from '../services/authMiddleware';

export default new Router({
  linkActiveClass: 'active',
  linkExactActiveClass: 'active',
  routes: [
    { path: '/', redirect: '/dashboard' },
    { path: '/login', component: AppLogin, beforeEnter: Guard.guest },
    { path: '/ingredients', component: Ingredients, beforeEnter: Guard.auth },
    {
      path: '/dashboard',
      component: CalendarDashboard,
      beforeEnter: Guard.auth,
    },
    { path: '/recipes', component: Recipes, beforeEnter: Guard.auth },
    {
      path: '/recipes/:id',
      component: EditRecipe,
      name: 'recipe',
      beforeEnter: Guard.auth,
      props: true,
    },
  ],
});
