<template>
<b-row>
  <b-col cols="8">
    <ingredients-table ref="ingredientsTable" @edit="editIngredient"></ingredients-table>
  </b-col>
  <b-col>
    <ingredient-form :ingredient="ingredient" @updated="resetAndRefetchIngredient" @reset="resetIngredient"></ingredient-form>
  </b-col>
</b-row>
</template>

<script>
import Form from './Form.vue'
import Table from './Table.vue'

export default {
  name: 'ingredients-index',
  components: {
    'ingredient-form': Form,
    'ingredients-table': Table
  },
  data () {
    return {
      ingredient: this.emptyIngredient()
    }
  },
  methods: {
    emptyIngredient() {
      return {id: null, name: '', protein: 0, fat: 0, carbonhydrate: 0, energy: 0}
    },
    resetAndRefetchIngredient() {
      this.resetIngredient()
      this.$refs.ingredientsTable.refetch()
    },
    resetIngredient () {
      this.ingredient = this.emptyIngredient()
    },
    editIngredient (item) {
      this.ingredient = item
    }
  }
}
</script>
