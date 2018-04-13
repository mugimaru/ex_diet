<template>
<div>
  <b-card
    no-body
    :border-variant="today ? 'info' : 'default'"
    class="calendar-widget">

    <div slot="header">
      {{calendar.day | moment("dddd, MMMM Do YYYY") }}

      <b-button-group class="float-right" size="sm">
        <b-button v-if="!edit" size="sm" variant="outline-secondary" @click="editCalendar">
          <icon name="edit"></icon>
        </b-button>
        <template v-else>
          <b-button variant="outline-success" size="sm" @click="confirmEdit">
            <icon name="check"></icon>
          </b-button>
          <b-button variant="outline-danger" size="sm" @click="cancelEdit">
            <icon name="times"></icon>
          </b-button>
        </template>
      </b-button-group>
    </div>

    <table class="table table-bordered" v-if="calendar && calendar.meals.length > 0">
      <thead>
        <th>Meal</th>
        <th>Weight</th>
        <th>Protein</th>
        <th>Fat</th>
        <th>Carbonhydrate</th>
        <th>Energy</th>
        <th v-if="edit"></th>
      </thead>
      <tbody>
        <tr v-for="(meal, i) in calendar.meals" :key="i">
          <template v-if="edit">
            <td>{{meal.recipe ? meal.recipe.name : meal.ingredient.name}}</td>
            <td>
              <b-input type="number" v-model="meal.weight"></b-input>
            </td>
            <td>{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
            <td></td>
          </template>
          <template v-else>
            <td>{{meal.recipe ? meal.recipe.name : meal.ingredient.name}}</td>
            <td>{{meal.weight | toFixed(0)}}</td>
            <td>{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
            <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
          </template>
        </tr>
      </tbody>
      <tfoot>
        <th colspan="2"></th>
        <th>{{totalNutritionFacts.protein | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.fat | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.carbonhydrate | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.energy | toFixed(0)}}</th>
        <th v-if="edit"></th>
      </tfoot>
    </table>
    <div class="card-body text-center" v-else> Empty </div>
  </b-card>
  <br/>
</div>
</template>

<script>

import moment from 'moment';
const nfKeys = ['protein', 'fat', 'carbonhydrate', 'energy']
const emptyNfData = () => nfKeys.reduce(function(acc, key){
  acc[key] = 0
  return acc
}, {})

export default {
  name: "calendar-widget",
  props: {
    calendar: { required: true }
  },
  computed: {
    mealsNutritionFacts(){
      return this.calendar.meals.map(function(meal) {
        const eatable = meal.recipe || meal.ingredient
        const weight = meal.weight
        return nfKeys.reduce(function(acc, n) {
          acc[n] = Number(eatable[n]) * weight / 100
          return acc
        }, {})
      })
    },
    totalNutritionFacts() {
      if(this.mealsNutritionFacts.length == 0) { return emptyNfData() }

      return this.mealsNutritionFacts.reduce(function(acc, item) {
        Object.keys(item).forEach((k) => acc[k] = (acc[k] || 0) + item[k])
        return acc
      }, {})
    },
    today() {
      return moment().isSame(this.calendar.day, 'day')
    }
  },
  data() {
    return {
      edit: false,
      backup: null
    }
  },
  methods: {
    editCalendar(){
      this.backup = this._.merge({}, this.calendar)
      this.edit = true
    },
    cancelEdit(){
      this.calendar = this.backup
      this.backup = null
      this.edit = false
    },
    confirmEdit(){
      this.backup = null
      this.edit = false
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
</style>
