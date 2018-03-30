<template>
  <div id="app">
    <b-container>
      <b-jumbotron header="Bootstrap Vue" v-bind:lead="msg"></b-jumbotron>
    </b-container>
  </div>
</template>

<script>

export default {
  name: 'app',
  data () {
    return {
      msg: 'Welcome to Your Vue.js & Phoenix & GraphQL App'
    }
  }
}
</script>

<style lang="scss">
</style>
