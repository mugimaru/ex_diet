<template>
<div id="app">
  <b-navbar toggleable="md" variant="info" type="dark">
    <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
    <router-link to="/" class="navbar-brand">
      <semipolar-spinner v-if="loading > 0" :animation-duration="2000" :size="30" color="#fff" />
      <template v-else> ExDiet </template>
    </router-link>

    <b-collapse is-nav id="nav_collapse">
      <b-navbar-nav>
        <b-nav-item to="/dashboard">Dashboard</b-nav-item>
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
    <timed-alert :message="message" @dismissed="message = null" variant="success"></timed-alert>
    <router-view></router-view>
  </b-container>
</div>
</template>

<script>
import { EventBus } from "./config/eventBus.js";
import { SemipolarSpinner } from "epic-spinners";

export default {
  name: "app",
  components: {
    SemipolarSpinner
  },
  computed: {
    userEmail() {
      return this.$root.$data.userEmail;
    }
  },
  methods: {
    logout() {
      localStorage.removeItem("userEmail");
      localStorage.removeItem("authToken");
      this.$root.$data.userEmail = localStorage.getItem("userEmail");
      this.$router.push({ path: "/login" });
    }
  },
  data() {
    return {
      message: null,
      loading: 0
    };
  },
  created() {
    EventBus.$on("notification", msg => (this.message = msg));
    EventBus.$on(
      "apollo-global-loading-state",
      state => (this.loading += state ? 1 : -1)
    );
  }
};
</script>

<style lang="scss">
</style>
