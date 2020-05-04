<template>
  <div class="apollo-errors-view">
    <b-list-group
      flush
      v-if="variant == 'list'"
      :show="!!error"
    >
      <b-list-group-item
        variant="danger"
        v-for="(error, i) in errorMessages"
        :key="i"
      >{{ error }}</b-list-group-item>
    </b-list-group>

    <b-alert
      v-if="variant == 'dismissible-alert'"
      :show="!!error"
      variant="danger"
      dismissible
    >
      <ul class="list-unstyled">
        <li
          v-for="(error, i) in errorMessages"
          :key="i"
        >{{ error }}</li>
      </ul>
    </b-alert>
  </div>
</template>

<script>
export default {
  name: 'apollo-errors-view',
  props: {
    variant: {
      default: 'list',
      type: String,
      validator: (v) => ['list', 'dismissible-alert'].includes(v),
    },
    error: Error,
  },
  computed: {
    errorMessages() {
      if (!this.error) {
        return [];
      }

      if (this.error.graphQLErrors && this.error.graphQLErrors.length > 0) {
        return this.error.graphQLErrors
          .map((e) => {
            if (e.code == 'validation_error') {
              return Object.keys(e.fields).map(
                (key) => `${key}: ${e.fields[key].join(', ')}`,
              );
            }
            return [e.message];
          })
          .reduce((a, b) => a.concat(b), []);
      }

      const ne = this.error.networkError;
      if (ne && ne.result && ne.result.errors && ne.result.errors.length > 0) {
        return ne.result.errors.map((e) => e.message);
      }

      return ne ? [ne.message] : [this.error.message];
    },
  },
  data() {
    return {};
  },
  methods: {},
};
</script>

<style>
.apollo-errors-view .alert > ul {
  margin-bottom: 0px;
}
</style>
