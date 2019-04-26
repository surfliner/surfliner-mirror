import mixin from '@/assets/scripts/app.js'
import Lark from '@/components/Lark'

export default {
  mixins: [mixin],
  name: 'Search',
  data: function() {
    return {
      authorities: [],
    }
  },
  components: {
    Lark
  },
  created() {
    this.search(this.$route.query.pref_label)
  },
  watch: {
    '$route': 'search'
  },
  methods: {
    async search(keywords) {
      fetch(this.$lark_url + 'search?pref_label=' + keywords, { mode: 'cors' })
        .then(this.$status)
        .then(this.$json)
        .then(data => { this.authorities = data; })
        .catch(error => { console.log('Request failed', error) });
    },
    displayItem(id) {
      this.$router.push({ path: `/${id}`});
    }
  },
  computed: {
    authoritiesCount() {
      return this.authorities ? this.authorities.length : 0;
    }
  }
}
