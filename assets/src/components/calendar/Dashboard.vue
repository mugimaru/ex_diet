<template>
<div>
  <div class="text-center">

    <b-button-group size="lg">
      <b-button variant="primary" @click="changeCalendarScope(-7)">Prev</b-button>
      <b-button variant="outline-primary" @click="returnToCurrentWeek">
        {{startDate | moment("MMMM Do YYYY")}} - {{endDate | moment("MMMM Do YYYY")}}
      </b-button>
      <b-button variant="primary" @click="changeCalendarScope(+7)"> Next </b-button>
    </b-button-group>
  </div>
  <br/>

  <b-row>
    <b-col cols="5"></b-col>
    <b-col cols="7">
      <calendar-widget
        v-for="(cal, i) in calendars"
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
import calendarWidget from './Widget.vue'
export default {
  name: "calendar-dashboard",
  components: {
    'calendar-widget': calendarWidget
  },
  computed: {
  },
  data() {
    return {
      calendars: null,
      startDate: moment().startOf('isoWeek'),
      endDate: moment().endOf('isoWeek')
    }
  },
  apollo: {
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
    },
    returnToCurrentWeek(){
      // do not refetch unless dates changed
      this.startDate = moment().startOf('isoWeek')
      this.endDate = moment().endOf('isoWeek')
      this.$apollo.queries.calendars.refetch()
    }
  }
};
</script>
