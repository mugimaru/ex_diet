<template>
<div>
  <b-list-group flush v-if="variant == 'list'" :show="!!error">
    <b-list-group-item variant="danger" v-for="(error, i) in errorMessages" :key="i">{{ error }}</b-list-group-item>
  </b-list-group>

  <b-alert v-if="variant == 'dismissible-alert'" :show="!!error" variant="danger" dismissible>
    <ul class="list-unstyled">
      <li v-for="(error, i) in errorMessages" :key="i">{{ error }}</li>
    </ul>
  </b-alert>
</div>
</template>

<script>
export default {
  name: "apollo-errors-view",
  props: {
    variant: {
      default: 'list',
      type: String,
      validator: (v) => ['list', 'dismissible-alert'].includes(v)
    },
    error: Error
  },
  computed: {
    errorMessages () {
      if(!this.error) { return []}

      if(this.error.graphQLErrors.length > 0) {
        return this.error.graphQLErrors.map(function(e) {
          if(e.code == "validation_error") {
            return Object.keys(e.fields).map(key => `${key}: ${e.fields[key].join(', ')}`)
          } else {
            return [e.message]
          }
        }).reduce((a, b) => a.concat(b), [])
      }

      const ne = this.error.networkError
      if(ne.result && ne.result.errors && ne.result.errors.length > 0) {
        return ne.result.errors.map((e) => e.message)
      }

      return [ne.message]
    }
  },
  data() {
    return {}
  },
  methods: {
  }
};
</script>
