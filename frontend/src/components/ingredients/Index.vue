<template>
  <div>
    <b-row>
      <b-col cols="8">
        <ingredients-table
          :search-enabled="true"
          ref="ingredientsTable"
          @edit="editIngredient"
          @deleted="onIngredientDeleted"
        ></ingredients-table>
      </b-col>
      <b-col>
        <ingredient-form
          :ingredient="ingredient"
          @updated="onUpdated"
          @created="onCreated"
          @reset="resetIngredient"
        ></ingredient-form>
      </b-col>
    </b-row>
  </div>
</template>

<script>
import { EventBus } from '@/config/eventBus';
import Form from './Form.vue';
import Table from './Table.vue';

export default {
  name: 'ingredients-index',
  components: {
    'ingredient-form': Form,
    'ingredients-table': Table,
  },
  data() {
    return {
      ingredient: this.emptyIngredient(),
    };
  },
  methods: {
    emptyIngredient() {
      return {
        id: null,
        name: '',
        protein: 0,
        fat: 0,
        carbonhydrate: 0,
        energy: 0,
      };
    },
    resetAndRefetchIngredient() {
      this.resetIngredient();
      this.$refs.ingredientsTable.refetch();
    },
    onUpdated(item) {
      this.publishOkMessage(item.name, 'updated');
      this.resetAndRefetchIngredient();
    },
    onCreated(item) {
      this.publishOkMessage(item.name, 'created');
      this.resetAndRefetchIngredient();
    },
    onIngredientDeleted(item) {
      this.publishOkMessage(item.name, 'deleted');
    },
    publishOkMessage(name, operation) {
      EventBus.$emit(
        'notification',
        `"${name}" has been successfully ${operation}.`,
      );
    },
    resetIngredient() {
      this.ingredient = this.emptyIngredient();
    },
    editIngredient(item) {
      this.ingredient = item;
    },
  },
};
</script>
