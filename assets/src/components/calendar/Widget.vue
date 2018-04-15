<template>
<div>
  <b-card
    no-body

    :border-variant="today ? 'info' : 'default'"
    class="calendar-widget">

    <div slot="header">
      {{calendar.day | moment("dddd, MMMM Do YYYY") }}

      <b-button-group class="float-right" size="sm">
        <b-button v-if="!editCalendar" size="sm" variant="outline-primary" @click="toggleChartMode">
          <span class="oi oi-pie-chart" aria-hidden="true" />
        </b-button>
        <b-button v-if="!editCalendar" size="sm" variant="outline-secondary" @click="startEditCalendar">
          <span class="oi oi-pencil" aria-hidden="true" />
        </b-button>
        <template v-else>
          <b-button variant="outline-success" size="sm" @click="confirmEdit">
            <span class="oi oi-check" aria-hidden="true" />
          </b-button>
          <b-button variant="outline-danger" size="sm" @click="cancelEdit">
            <span class="oi oi-circle-x" aria-hidden="true" />
          </b-button>
        </template>
      </b-button-group>
    </div>

    <b-row id="chart-view" v-show="hasAnyData && chartMode" class="float-left">
      <b-col cols="6">
        <pie-chart :library="{ title: `Total energy - ${totalNutritionFacts.energy.toFixed(0)}kcal` }" :data="chartData"></pie-chart>
      </b-col>
    </b-row>
    <div class="card-body text-center" v-show="!hasAnyData">
      <b-button-group v-if="editCalendar">
        <b-button variant="outline-primary" @click="addRecipeMeal"> Add recipe </b-button>
        <b-button variant="outline-success" @click="addIngredientMeal"> Add ingredient </b-button>
      </b-button-group>
      <span v-if="!editCalendar"> Empty </span>
    </div>
    <table fixed class="table table-bordered" v-if="hasAnyData && !chartMode">
      <thead>
        <th>Meal</th>
        <th>Weight</th>
        <th>Protein</th>
        <th>Fat</th>
        <th>Carbonhydrate</th>
        <th>Energy</th>
        <th v-if="editCalendar">
          <b-button-group size="sm" v-if="editCalendar">
            <b-button variant="outline-primary" @click="addRecipeMeal">
              <span class="oi oi-plus" aria-hidden="true" /> Recipe
            </b-button>
            <b-button variant="outline-success" @click="addIngredientMeal">
              <span class="oi oi-plus" aria-hidden="true" /> Ingredient
            </b-button>
          </b-button-group>
        </th>
      </thead>
      <draggable v-if="editCalendar" v-model="editCalendar.meals" :element="'tbody'">
        <tr v-for="(meal, i) in editCalendar.meals" :key="i">
          <td v-if="meal.ingredient">
            <ingredients-search-input
              :allow-add-new="false"
              v-model="meal.ingredient"
              @input="meal.ingredientId = meal.ingredient.id" />
          </td>
          <td v-else>
            <recipes-select
              :recipes="allRecipes"
              v-model="meal.recipe"
              @input="meal.recipeId = meal.recipe.id" />
          </td>
          <td>
            <b-input type="number" v-model="meal.weight"></b-input>
          </td>
          <td>{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
          <td>
            <b-button variant="outline-danger" size="sm" @click="removeMeal(meal)">Remove</b-button>
          </td>
        </tr>
      </draggable>
      <tbody v-else>
        <tr v-for="(meal, i) in calendar.meals" :key="i">
          <td>{{meal.recipe ? meal.recipe.name : meal.ingredient.name}}</td>
          <td>{{meal.weight | toFixed(0)}}</td>
          <td>{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
        </tr>
      </tbody>
      <tfoot>
        <th colspan="2"></th>
        <th>{{totalNutritionFacts.protein | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.fat | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.carbonhydrate | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.energy | toFixed(0)}}</th>
        <th v-if="editCalendar"></th>
      </tfoot>
    </table>
  </b-card>
  <br/>
</div>
</template>

<script>
import createCalendarMutation from "@/graphql/mutations/createCalendar.graphql";
import updateCalendarMutation from "@/graphql/mutations/updateCalendar.graphql";

import ingredientsSearchInput from "@/components/ingredients/SearchInput.vue";
import recipesSelect from "./RecipesSelect.vue";

import moment from "moment";
const nfKeys = ["protein", "fat", "carbonhydrate", "energy"];
const emptyNfData = () =>
  nfKeys.reduce(function(acc, key) {
    acc[key] = 0;
    return acc;
  }, {});

export default {
  name: "calendar-widget",
  components: {
    "ingredients-search-input": ingredientsSearchInput,
    "recipes-select": recipesSelect
  },
  props: {
    allRecipes: { required: true },
    calendar: { required: true }
  },
  data() {
    return {
      editCalendar: null,
      chartMode: false
    };
  },
  computed: {
    chartData() {
      return [
        ["Protein", this.totalNutritionFacts.protein],
        ["Fat", this.totalNutritionFacts.fat],
        ["Carbonhydrate", this.totalNutritionFacts.carbonhydrate]
      ];
    },
    hasAnyData() {
      return (
        (this.editCalendar && this.editCalendar.meals.length > 0) ||
        (this.calendar && this.calendar.meals.length > 0)
      );
    },
    calendarMutationParams() {
      if (!this.editCalendar) {
        return {};
      }

      return {
        day: this.calendar.day,
        meals: this.editCalendar.meals.map(function(meal, i) {
          return {
            position: i,
            weight: Number(meal.weight),
            ingredientId: meal.ingredientId,
            recipeId: meal.recipeId
          };
        })
      };
    },
    mealsNutritionFacts() {
      const calendar = this.editCalendar || this.calendar;

      return calendar.meals.map(function(meal) {
        const eatable = meal.recipe || meal.ingredient;
        const weight = meal.weight;
        return nfKeys.reduce(function(acc, n) {
          acc[n] = Number(eatable[n]) * weight / 100;
          return acc;
        }, {});
      });
    },
    totalNutritionFacts() {
      if (this.mealsNutritionFacts.length == 0) {
        return emptyNfData();
      }

      return this.mealsNutritionFacts.reduce(function(acc, item) {
        Object.keys(item).forEach(k => (acc[k] = (acc[k] || 0) + item[k]));
        return acc;
      }, {});
    },
    today() {
      return moment().isSame(this.calendar.day, "day");
    }
  },
  methods: {
    addRecipeMeal() {
      this.editCalendar.meals.push({ weight: 0, recipeId: null, recipe: {} });
    },
    addIngredientMeal() {
      this.editCalendar.meals.push({
        weight: 0,
        ingredientId: null,
        ingredient: {}
      });
    },
    removeMeal(meal) {
      this.editCalendar.meals.splice(this.editCalendar.meals.indexOf(meal), 1);
    },
    startEditCalendar() {
      this.editCalendar = this._.merge({}, this.calendar);
    },
    cancelEdit() {
      this.editCalendar = null;
    },
    confirmEdit() {
      let vars = { input: this.calendarMutationParams };
      if (this.calendar.id) {
        vars.id = this.calendar.id;
      }

      this.$apollo
        .mutate({
          mutation: this.editCalendar.id
            ? updateCalendarMutation
            : createCalendarMutation,
          variables: vars
        })
        .then(result => {
          this.$emit("updated", this.editCalendar);
          this.editCalendar = null;
        })
        .catch(e => {
          console.dir(e);
        });
    },
    toggleChartMode() {
      this.chartMode = !this.chartMode;
      console.log(this.chartMode);
    }
  },
  filters: {
    toFixed: (value, prescision) => Number(value).toFixed(prescision)
  }
};
</script>

<style>
.calendar-widget table {
  margin: 0px;
}

#chart-view {
  margin-top: 1.25rem;
}
</style>
