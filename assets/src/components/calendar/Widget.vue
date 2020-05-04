<template>
  <div>
    <b-card
      no-body
      :border-variant="today ? 'info' : 'default'"
      class="calendar-widget"
    >

      <div slot="header">
        {{calendar.day | moment("dddd, MMMM Do YYYY") }}

        <b-button-group
          class="float-right"
          size="sm"
        >
          <b-button
            v-if="!editCalendar"
            variant="outline-primary"
            @click="toggleChartMode"
          >
            <span
              class="oi oi-pie-chart"
              aria-hidden="true"
            />
          </b-button>
          <b-button
            v-if="!editCalendar"
            variant="outline-secondary"
            @click="startEditCalendar"
          >
            <span
              class="oi oi-pencil"
              aria-hidden="true"
            />
          </b-button>
          <template v-else>
            <b-button
              variant="outline-success"
              size="sm"
              @click="confirmEdit"
              :disabled="!!$v.editCalendar.$invalid"
            >
              <span
                class="oi oi-check"
                aria-hidden="true"
              />
            </b-button>
            <b-button
              variant="outline-danger"
              size="sm"
              @click="cancelEdit"
            >
              <span
                class="oi oi-circle-x"
                aria-hidden="true"
              />
            </b-button>
          </template>
        </b-button-group>
      </div>

      <b-row
        id="chart-view"
        v-show="hasAnyData && chartMode"
        class="float-left"
      >
        <b-col
          cols="12"
          md="6"
        >
          <pie-chart
            :library="{ title: `Total energy - ${totalNutritionFacts.energy.toFixed(0)}kcal` }"
            :data="chartData"
          ></pie-chart>
        </b-col>
      </b-row>
      <div
        class="card-body text-center"
        v-show="!hasAnyData"
      >
        <b-button-group v-if="editCalendar">
          <b-button
            variant="outline-primary"
            @click="addRecipeMeal"
          > Add recipe </b-button>
          <b-button
            variant="outline-success"
            @click="addIngredientMeal"
          > Add ingredient </b-button>
        </b-button-group>
        <span v-if="!editCalendar"> Empty </span>
      </div>
      <table
        class="table table-bordered widget-table"
        v-if="hasAnyData && !chartMode"
      >
        <thead>
          <th>Meal</th>
          <th>Weight</th>
          <th class="d-none d-md-table-cell">Protein</th>
          <th class="d-none d-md-table-cell">Fat</th>
          <th class="d-none d-md-table-cell">Carbonhydrate</th>
          <th>Energy</th>
          <template v-if="editCalendar">
            <th class="d-block d-md-none">
              <b-dropdown
                variant="outline-primary"
                size="sm"
                right
              >
                <template slot="button-content"> <span
                    class="oi oi-plus"
                    aria-hidden="true"
                  /> </template>
                <b-dropdown-item @click="addRecipeMeal"> Recipe </b-dropdown-item>
                <b-dropdown-item @click="addIngredientMeal"> Ingredient </b-dropdown-item>
              </b-dropdown>
            </th>

            <th class="d-none d-md-table-cell">
              <b-button-group
                size="sm"
                v-if="editCalendar"
              >
                <b-button
                  variant="outline-primary"
                  @click="addRecipeMeal"
                >
                  <span
                    class="oi oi-plus"
                    aria-hidden="true"
                  /> Recipe
                </b-button>
                <b-button
                  variant="outline-success"
                  @click="addIngredientMeal"
                >
                  <span
                    class="oi oi-plus"
                    aria-hidden="true"
                  /> Ingredient
                </b-button>
              </b-button-group>
            </th>
          </template>
        </thead>
        <draggable
          v-if="editCalendar"
          v-model="editCalendar.meals"
          :tag="'tbody'"
        >
          <tr
            v-for="(meal, i) in editCalendar.meals"
            :key="meal.id || meal.tmpId"
          >
            <td v-if="meal.ingredient">
              <ingredients-search-input
                size="sm"
                :allow-add-new="false"
                v-model="meal.ingredient"
                @input="meal.ingredientId = meal.ingredient.id"
                :state="!$v.editCalendar.meals.$each[i].ingredientId.$invalid"
              />
            </td>
            <td v-else>
              <recipes-select
                size="sm"
                :recipes="allRecipes"
                v-model="meal.recipe"
                @input="meal.recipeId = meal.recipe.id"
                :state="!$v.editCalendar.meals.$each[i].recipeId.$invalid"
              />
            </td>
            <td>
              <b-input
                type="number"
                v-model="meal.weight"
                size="sm"
                :state="!$v.editCalendar.meals.$each[i].weight.$invalid"
              />
            </td>
            <td class="d-none d-md-table-cell">{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
            <td class="d-none d-md-table-cell">{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
            <td class="d-none d-md-table-cell">{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
            <td>
              <b-button
                variant="outline-danger"
                size="sm"
                block
                @click="removeMeal(meal)"
              >
                <span
                  class="oi oi-ban"
                  aria-hidden="true"
                />
              </b-button>
            </td>
          </tr>
        </draggable>
        <tbody v-else>
          <tr
            v-for="(meal, i) in calendar.meals"
            :key="i"
          >
            <td>{{meal.recipe ? meal.recipe.name : meal.ingredient.name}}</td>
            <td>{{meal.weight | toFixed(0)}}</td>
            <td class="d-none d-md-table-cell">{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
            <td class="d-none d-md-table-cell">{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
            <td class="d-none d-md-table-cell">{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
          </tr>
        </tbody>
        <tfoot>
          <th colspan="2"></th>
          <th class="d-none d-md-table-cell">{{totalNutritionFacts.protein | toFixed(2)}}</th>
          <th class="d-none d-md-table-cell">{{totalNutritionFacts.fat | toFixed(2)}}</th>
          <th class="d-none d-md-table-cell">{{totalNutritionFacts.carbonhydrate | toFixed(2)}}</th>
          <th>{{totalNutritionFacts.energy | toFixed(0)}}</th>
          <th v-if="editCalendar"></th>
        </tfoot>
      </table>
    </b-card>
    <br />
  </div>
</template>

<script>
import createCalendarMutation from '@/graphql/mutations/createCalendar.graphql';
import updateCalendarMutation from '@/graphql/mutations/updateCalendar.graphql';

import ingredientsSearchInput from '@/components/ingredients/SearchInput.vue';
import {
  required,
  requiredIf,
  minValue,
  minLength,
} from 'vuelidate/lib/validators';

import moment from 'moment';
import recipesSelect from './RecipesSelect.vue';

const nfKeys = ['protein', 'fat', 'carbonhydrate', 'energy'];
const emptyNfData = () => nfKeys.reduce((acc, key) => {
  acc[key] = 0;
  return acc;
}, {});

const ID = () => `_${
  Math.random()
    .toString(36)
    .substr(2, 9)}`;

export default {
  name: 'calendar-widget',
  components: {
    'ingredients-search-input': ingredientsSearchInput,
    'recipes-select': recipesSelect,
  },
  props: {
    allRecipes: { required: true },
    calendar: { required: true },
  },
  data() {
    return {
      editCalendar: null,
      chartMode: false,
    };
  },
  computed: {
    chartData() {
      return [
        ['Protein', this.totalNutritionFacts.protein],
        ['Fat', this.totalNutritionFacts.fat],
        ['Carbonhydrate', this.totalNutritionFacts.carbonhydrate],
      ];
    },
    hasAnyData() {
      return (
        (this.editCalendar && this.editCalendar.meals.length > 0)
        || (this.calendar && this.calendar.meals.length > 0)
      );
    },
    calendarMutationParams() {
      if (!this.editCalendar) {
        return {};
      }

      return {
        day: this.calendar.day,
        meals: this.editCalendar.meals.map((meal, i) => ({
          position: i,
          weight: Number(meal.weight),
          ingredientId: meal.ingredientId,
          recipeId: meal.recipeId,
        })),
      };
    },
    mealsNutritionFacts() {
      const calendar = this.editCalendar || this.calendar;

      return calendar.meals.map((meal) => {
        const eatable = meal.recipe || meal.ingredient;
        const { weight } = meal;
        return nfKeys.reduce((acc, n) => {
          acc[n] = Number(eatable[n]) * weight / 100;
          return acc;
        }, {});
      });
    },
    totalNutritionFacts() {
      if (this.mealsNutritionFacts.length == 0) {
        return emptyNfData();
      }

      return this.mealsNutritionFacts.reduce((acc, item) => {
        Object.keys(item).forEach((k) => (acc[k] = (acc[k] || 0) + item[k]));
        return acc;
      }, {});
    },
    today() {
      return moment().isSame(this.calendar.day, 'day');
    },
  },
  methods: {
    addRecipeMeal() {
      this.editCalendar.meals.push({
        tmpId: ID(),
        weight: 0,
        recipeId: null,
        recipe: {},
      });
    },
    addIngredientMeal() {
      this.editCalendar.meals.push({
        tmpId: ID(),
        weight: 0,
        ingredientId: null,
        ingredient: {},
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
      const vars = { input: this.calendarMutationParams };
      if (this.calendar.id) {
        vars.id = this.calendar.id;
      }

      this.$apollo
        .mutate({
          mutation: this.editCalendar.id
            ? updateCalendarMutation
            : createCalendarMutation,
          variables: vars,
        })
        .then((result) => {
          this.$emit('updated', this.editCalendar);
          this.editCalendar = null;
        })
        .catch((e) => {
          console.dir(e);
        });
    },
    toggleChartMode() {
      this.chartMode = !this.chartMode;
    },
  },
  validations() {
    return {
      editCalendar: {
        meals: {
          $each: {
            weight: { required, minValue: minValue(1) },
            ingredientId: {
              required: requiredIf((meal) => !meal.recipe),
            },
            recipeId: {
              required: requiredIf((meal) => !meal.ingredient),
            },
          },
        },
      },
    };
  },
  filters: {
    toFixed: (value, prescision) => Number(value).toFixed(prescision),
  },
};
</script>

<style>
.calendar-widget table {
  margin: 0px;
}

#chart-view {
  margin-top: 1.25rem;
}
.widget-table > thead > th:nth-child(8) {
  width: 10px !important;
  white-space: nowrap;
}
</style>
