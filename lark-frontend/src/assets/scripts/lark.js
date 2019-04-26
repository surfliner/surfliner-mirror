import Banner from '@/components/Banner'
import mixin from '@/assets/scripts/app'

export default {
  mixins: [mixin],
  name: 'Lark',
  data: function() {
    return {
      searchText: ''
    }
  },
  components: {
    Banner
  },
  methods: {
    newAuthority() {
      this.$router.push({ name: "New"})
    },
    search() {
      this.$router.push({ path: '/search', query: { 'pref_label': this.searchText }})
      // reload the page
      this.$router.go()
    }
  }
}
