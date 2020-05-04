<template>
  <b-alert
    :show="cd"
    dismissible
    :variant="variant"
    @dismissed="cd = 0"
    @dismiss-count-down="onCountDownChanged"
  >
    {{msg}}
  </b-alert>
</template>

<script>
function isObject(value) {
  return value && typeof value === 'object' && value.constructor === Object;
}

export default {
  name: 'apollo-errors-view',
  props: {
    dismissAfter: { type: Number, default: 3 },
    variant: { type: String, default: 'success' },
    message: {},
  },
  watch: {
    message() {
      this.cd = this.dismissTime;
    },
  },
  computed: {
    alertVariant() {
      if (isObject(this.message) && this.message.variant) {
        return this.message.variant;
      }
      return this.variant;
    },
    msg() {
      if (isObject(this.message) && this.message.message) {
        return this.message.message;
      }
      return this.message;
    },
    dismissTime() {
      if (isObject(this.message) && this.message.dismissAfter) {
        return this.message.dismissAfter;
      }
      return this.dismissAfter;
    },
  },
  data() {
    return {
      cd: 0,
    };
  },
  methods: {
    onCountDownChanged(newCd) {
      this.cd = newCd;
    },
  },
};
</script>
