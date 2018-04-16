<template>
  <b-form-select
    v-model="selected"
    :options="options"
    @change="onChange"
    :state="state" />
</template>

<script>
export default {
  name: "recipes-search",
  props: ["value", "recipes", "state"],
  data() {
    return {
      selected: null
    };
  },
  computed: {
    options() {
      return this.recipes.map(function(recipe) {
        return { value: recipe, text: recipe.name };
      });
    }
  },
  methods: {
    onChange(selected) {
      this.$emit("input", selected);
    }
  },
  created() {
    const recipe = this.recipes.find(rec => rec.id == this.value.id);
    if (recipe) {
      this.selected = recipe;
    }
  }
};
</script>
