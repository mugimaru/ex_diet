<template>
  <b-jumbotron
    bg-variant="info"
    text-variant="white"
    border-variant="dark"
  >
    <template slot="header">
      ExDiet
    </template>
    <template slot="lead">
      <p v-if="this.$root.$data.userEmail">
        You are logged in as {{ this.$root.$data.userEmail }}.
      </p>
      <router-link
        v-else
        to="/login"
        class="btn btn-lg btn-success"
      >Login or register</router-link>
    </template>

  </b-jumbotron>
</template>

<script>
import ingredientsSearchInput from './ingredients/SearchInput.vue';

export default {
  name: 'index',
  data() {
    return {};
  },
  methods: {},
};
</script>
