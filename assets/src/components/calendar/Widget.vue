<template>
<div>
  <b-card
    no-body
    border-variant="info"
    :header-bg-variant="today ? 'info' : 'default'"
    :header-text-variant="today ? 'white' : 'black'"
    class="calendar-widget">

    <div slot="header">
      {{calendar.day | moment("dddd, MMMM Do YYYY") }}
    </div>

    <table class="table table-bordered">
      <thead>
        <th>Meal</th>
        <th>Weight</th>
        <th>Protein</th>
        <th>Fat</th>
        <th>Carbonhydrate</th>
        <th>Energy</th>
        <th></th>
      </thead>
      <tbody>
        <tr v-for="(meal, i) in calendar.meals" :key="i">
          <td>{{meal.recipe ? meal.recipe.name : meal.ingredient.name}}</td>
          <td>{{meal.weight | toFixed(0)}}</td>
          <td>{{mealsNutritionFacts[i].protein | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].fat | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].carbonhydrate | toFixed(2)}}</td>
          <td>{{mealsNutritionFacts[i].energy | toFixed(0)}}</td>
          <td></td>
        </tr>
      </tbody>
      <tfoot>
        <th colspan="2"></th>
        <th>{{totalNutritionFacts.protein | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.fat | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.carbonhydrate | toFixed(2)}}</th>
        <th>{{totalNutritionFacts.energy | toFixed(0)}}</th>
        <th></th>
      </tfoot>
    </table>
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
    today(date) {
      return moment().diff(moment(this.calendar.day), 'days') == 0
    }
  },
  data() {
    return {}
  },
  methods: {
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
