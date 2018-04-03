export default {
  guest (to, from, next) {
    next(!localStorage.getItem('userEmail'));
  },

  auth (to, from, next) {
    next(localStorage.getItem('authToken') ? true : {
      path: '/login',
      query: {
        redirect: to.name
      }
    });
  }
};
