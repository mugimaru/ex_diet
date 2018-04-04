<template>
<div id="app">
  <b-navbar toggleable="md" variant="info" type="dark">
    <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
    <router-link to="/" class="navbar-brand">ExDiet</router-link>

    <b-collapse is-nav id="nav_collapse">
      <b-navbar-nav>
        <b-nav-item to="/ingredients">Ingredients</b-nav-item>
        <b-nav-item to="/recipes">Recipes</b-nav-item>
      </b-navbar-nav>

      <b-navbar-nav class="ml-auto">
        <b-nav-item-dropdown right v-if="userEmail">
          <template slot="button-content">
            <em>{{ userEmail }}</em>
          </template>
          <b-dropdown-item @click="logout()">Logout</b-dropdown-item>
        </b-nav-item-dropdown>
        <b-nav-item v-else to="login">login</b-nav-item>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
  <br>

  <b-container fluid>
    <router-view></router-view>
  </b-container>
</div>
</template>

<script>

export default {
  name: 'app',
  computed: {
    userEmail () {
      return this.$root.$data.userEmail
    }
  },
  methods: {
    logout () {
      localStorage.removeItem("userEmail")
      localStorage.removeItem("authToken")
      this.$root.$data.userEmail = localStorage.getItem("userEmail")
      this.$router.push({path: '/login'})
    }
  },
  data () {
    return {}
  }
}
</script>

<style lang="scss">
</style>
