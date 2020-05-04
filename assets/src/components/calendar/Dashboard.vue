<template>
  <div>
    <b-row>
      <b-col cols="12">
        <div class="text-center">
          <b-button-group>
            <b-button
              variant="primary"
              @click="changeCalendarScope(-7)"
            >
              <span
                class="oi oi-chevron-left"
                aria-hidden="true"
              />
            </b-button>
            <b-button
              variant="outline-primary"
              @click="returnToCurrentWeek"
            >
              {{startDate | moment("MMMM Do YYYY")}} - {{endDate | moment("MMMM Do YYYY")}}
            </b-button>
            <b-button
              variant="primary"
              @click="changeCalendarScope(+7)"
            >
              <span
                class="oi oi-chevron-right"
                aria-hidden="true"
              />
            </b-button>
          </b-button-group>
        </div>
      </b-col>
      <b-col
        cols="12"
        class="d-none d-md-block"
      >
        <div class="text-right">
          <b-form-checkbox v-model="hideCalendarsBeforeToday">
            Hide widgets before today
          </b-form-checkbox>
        </div>
      </b-col>
      <b-col
        cols="12"
        class="d-block d-md-none"
      >
        <br />
        <div class="text-center">
          <b-form-checkbox v-model="hideCalendarsBeforeToday">
            Hide widgets before today
          </b-form-checkbox>
        </div>
      </b-col>
    </b-row>
    <br />

    <b-row>
      <b-col
        cols="12"
        md="4"
      >

        <apollo-errors-view
          variant="dismissible-alert"
          :error="error"
        ></apollo-errors-view>
        <b-card
          no-body
          header="Recipes"
          id="recipes-card"
        >
          <b-list-group flush>
            <b-list-group-item
              :disabled="recipe.eaten"
              v-for="recipe in recipes"
              :key="recipe.id"
              class="d-flex justify-content-between align-items-center"
            >
              <span>
                <b-badge variant="secondary">
                  {{recipe.protein | toFixed(0)}}/{{recipe.fat | toFixed(0)}}/{{recipe.carbonhydrate | toFixed(0)}} - {{recipe.energy | toFixed(0)}}kcal
                </b-badge>
                {{recipe.name}}
              </span>
              <b-button
                variant="outline-danger"
                size="sm"
                v-if="!recipe.eaten"
                @click="markAsEaten(recipe.id)"
              >
                <span
                  class="oi oi-check"
                  aria-hidden="true"
                />
              </b-button>
            </b-list-group-item>
          </b-list-group>
        </b-card>
      </b-col>
      <b-col
        cols="12"
        md="8"
      >
        <calendar-widget
          v-for="(cal, i) in calendarsForWeek"
          :key="i"
          :calendar="cal"
          :allRecipes="recipes"
          @updated="$apollo.queries.calendars.refetch()"
        />
      </b-col>
    </b-row>
  </div>
</template>

<script>
import moment from 'moment';
import listCalendarsQuery from '@/graphql/queries/listCalendars.graphql';
import listRecipesQuery from '@/graphql/queries/listRecipes.graphql';
import updateRecipeMutation from '@/graphql/mutations/updateRecipe.graphql';
import calendarWidget from './Widget.vue';

export default {
  name: 'calendar-dashboard',
  components: {
    'calendar-widget': calendarWidget,
  },
  computed: {
    eatenRecipes() {
      if (!this.calendars) {
        return [];
      }

      const notEatenRecipesId = this.notEatenRecipes.map((edge) => edge.node.id);
      return this._.uniqBy(
        this._.compact(
          this._.flatMap(this.calendars, (cal) => cal.meals.map((meal) => meal.recipe),
          ),
        ),
        (recipe) => recipe.id,
      ).filter((recipe) => !notEatenRecipesId.includes(recipe.id));
    },
    recipes() {
      if (!this.notEatenRecipes) {
        return [];
      }
      return [
        ...this.notEatenRecipes.map((edge) => edge.node),
        ...this.eatenRecipes,
      ];
    },
    calendarsForWeek() {
      if (!this.calendars) {
        return null;
      }
      let { startDate } = this;
      let range = 7;
      const today = moment();

      if (this.hideCalendarsBeforeToday) {
        if (startDate.isAfter(today) || this.endDate.isBefore(today)) {
          return [];
        }
        startDate = today;
        range = this.endDate.diff(today, 'days') + 1;
      }

      const comp = this;
      return this._.range(range).map((n) => {
        const date = n == 0 ? moment(startDate) : moment(startDate).add(n, 'days');
        const cal = comp.calendars.find(cal => date.isSame(cal.day, "day"));

        return cal || { day: date.format('YYYY-MM-DD'), meals: [] };
      });
    },
  },
  data() {
    return {
      notEatenRecipes: null,
      calendars: null,
      hideCalendarsBeforeToday: true,
      error: null,
      startDate: moment().startOf('isoWeek'),
      endDate: moment().endOf('isoWeek'),
    };
  },
  apollo: {
    notEatenRecipes: {
      query: listRecipesQuery,
      variables: {
        eaten: false,
        first: 30,
      },
      update: (data) => data.listRecipes.edges,
      error(e) {
        this.error = e;
      },
    },
    calendars: {
      query: listCalendarsQuery,
      variables() {
        return {
          filter: {
            before: moment(this.endDate).toISOString(),
            after: moment(this.startDate).toISOString(),
          },
        };
      },
      update: (data) => data.listCalendars,
      error(e) {
        this.error = e;
      },
    },
  },
  methods: {
    changeCalendarScope(days) {
      this.startDate = moment(this.startDate).add(days, 'days');
      this.endDate = moment(this.endDate).add(days, 'days');
      this.changeSetHideCalendarsBeforeToday();
      this.$apollo.queries.calendars.refetch();
    },
    changeSetHideCalendarsBeforeToday() {
      this.hideCalendarsBeforeToday =
        moment(this.startDate).isSame(moment().startOf("isoweek"), "day") &&
        moment(this.endDate).isSame(moment().endOf("isoWeek"), "day");
    },
    returnToCurrentWeek() {
      const startOfCurrentWeek = moment().startOf('isoWeek');
      const endOfCurrentWeek = moment().endOf('isoWeek');

      if (
        moment(this.startDate).isSame(startOfCurrentWeek, 'day')
        && moment(this.endDate).isSame(endOfCurrentWeek, 'day')
      ) {
        return;
      }

      this.startDate = startOfCurrentWeek;
      this.endDate = endOfCurrentWeek;
      this.changeSetHideCalendarsBeforeToday();
      this.$apollo.queries.calendars.refetch();
    },
    markAsEaten(recipeId) {
      this.$apollo
        .mutate({
          mutation: updateRecipeMutation,
          variables: { id: recipeId, input: { eaten: true } },
        })
        .then((result) => {
          this.$apollo.queries.notEatenRecipes.refetch();
          this.$apollo.queries.calendars.refetch();
        })
        .catch((e) => {
          this.error = e;
        });
    },
  },
  filters: {
    toFixed: (value, prescision) => Number(value).toFixed(prescision),
  },
};
</script>

<style>
#recipes-card {
  margin-bottom: 1.25rem;
}
</style>
