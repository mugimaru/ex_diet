<template>
  <b-form-select
    v-model="selected"
    :options="options"
    @change="onChange" />
</template>

<script>

export default {
  name: 'recipes-search',
  props: ['value', 'recipes'],
  data () {
    return {
      selected: null
    }
  },
  computed: {
    options () {
      return this.recipes.map(function(recipe) {
        return { value: recipe, text: recipe.name }
      })
    }
  },
  methods: {
    onChange(selected){
      this.$emit('input', selected)
    }
  },
  created() {
    this.selected = this.value
  }
}
</script>
