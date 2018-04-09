<template>
<div>
  <div class="text-center">

    <b-button-group size="lg">
      <b-button variant="primary" @click="changeCalendarScope(-7)">
        <icon name="chevron-left"></icon>
      </b-button>
      <b-button variant="outline-primary" @click="returnToCurrentWeek">
        {{startDate | moment("MMMM Do YYYY")}} - {{endDate | moment("MMMM Do YYYY")}}
      </b-button>
      <b-button variant="primary" @click="changeCalendarScope(+7)">
        <icon name="chevron-right"></icon>
      </b-button>
    </b-button-group>
  </div>

  <div class="text-right">
    <b-form-checkbox v-model="hideCalendarsBeforeToday">
      Hide widgets before today
    </b-form-checkbox>
  </div>
  <br/>

  <b-row>
    <b-col cols="5">

      <b-card no-body header="Recipes">
        <b-list-group flush>
          <b-list-group-item :disabled="recipe.eaten" v-for="(recipe, i) in recipes" :key="recipe.id" class="d-flex justify-content-between align-items-center">
            <span>
            <b-badge variant="secondary">
              {{recipe.protein | toFixed(0)}}/{{recipe.fat | toFixed(0)}}/{{recipe.carbonhydrate | toFixed(0)}} - {{recipe.energy | toFixed(0)}}kcal
            </b-badge>
            {{recipe.name}}
            </span>
            <b-button variant="outline-danger" size="sm" v-if="!recipe.eaten" @click="markAsEaten(recipe.id)">
              <icon name="check" scale="1"></icon>
            </b-button>
          </b-list-group-item>
        </b-list-group>
      </b-card>
    </b-col>
    <b-col cols="7">
      <calendar-widget
        v-for="(cal, i) in calendarsForWeek"
        :key="i"
        :calendar="cal">
      </calendar-widget>
    </b-col>
  </b-row>
</div>
</template>

<script>

import moment from 'moment'
import listCalendarsQuery from '../../graphql/queries/listCalendars.graphql'
import listRecipesQuery from '../../graphql/queries/listRecipes.graphql'
import calendarWidget from './Widget.vue'
export default {
  name: "calendar-dashboard",
  components: {
    'calendar-widget': calendarWidget
  },
  computed: {
    eatenRecipes(){
      if(!this.calendars) { return [] }

      const notEatenRecipesId = this.notEatenRecipes.map((edge) => edge.node.id)
      return this._.compact(
        this._.flatMap(this.calendars, (cal) => (
          cal.meals.map((meal) => meal.recipe)
        ))
      ).filter((recipe) => !notEatenRecipesId.includes(recipe.id))
    },
    recipes(){
      if(!this.notEatenRecipes) { return [] }
      return [...this.notEatenRecipes.map((edge) => edge.node), ... this.eatenRecipes]
    },
    calendarsForWeek() {
      if(!this.calendars) { return null }
      let startDate = this.startDate
      let range = 7
      const today = moment()

      if(this.hideCalendarsBeforeToday) {
        if(startDate.isAfter(today) || this.endDate.isBefore(today)) { return [] }
        startDate = today
        range = this.endDate.diff(today, 'days') + 1
      }

      const comp = this
      return this._.range(range).map(function(n) {
        const date = n == 0 ? moment(startDate) : moment(startDate).add(n, 'days')
        const cal = comp.calendars.find((cal) => date.isSame(cal.day, 'day'))

        return cal ? cal : { day: date, meals: [] }
      })
    }
  },
  data() {
    return {
      notEatenRecipes: null,
      calendars: null,
      hideCalendarsBeforeToday: true,
      startDate: moment().startOf('isoWeek'),
      endDate: moment().endOf('isoWeek')
    }
  },
  apollo: {
    notEatenRecipes: {
      query: listRecipesQuery,
      variables: {
        eaten: false,
        first: 30
      },
      update: data => data.listRecipes.edges,
      error(e) {
        console.dir(e)
      }
    },
    calendars: {
      query: listCalendarsQuery,
      variables() {
        return {
          filter: {
            before: moment(this.endDate).toISOString(),
            after: moment(this.startDate).toISOString()
          }
        }
      },
      update: data => data.listCalendars,
      error(e) {
        console.dir(e)
      }
    }
  },
  methods: {
    changeCalendarScope(days) {
      this.startDate = moment(this.startDate).add(days, 'days')
      this.endDate = moment(this.endDate).add(days, 'days')
      this.$apollo.queries.calendars.refetch()
      this.hideCalendarsBeforeToday = false
    },
    returnToCurrentWeek(){
      const startOfCurrentWeek = moment().startOf('isoWeek')
      const endOfCurrentWeek = moment().endOf('isoWeek')

      if(moment(this.startDate).isSame(startOfCurrentWeek, 'day') && moment(this.endDate).isSame(endOfCurrentWeek, 'day')) {
        return
      }

      this.startDate = startOfCurrentWeek
      this.endDate = endOfCurrentWeek
      this.$apollo.queries.calendars.refetch()
      this.hideCalendarsBeforeToday = true
    },
    markAsEaten(recipeId) {
      alert(`Mark "${recipeId}" as eaten`)
    }
  },
  filters: {
    toFixed: (value, prescision) => Number(value).toFixed(prescision)
  }
};
</script>
