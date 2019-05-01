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
    search(keywords) {
      this.$flashStorage.destroyAll(); // destroy all flash messages
      this.axios.get(this.$lark_url + 'search?pref_label=' + keywords, { mode: "cors" })
        .then(response => { this.authorities = response.data; })
        .catch(error => {
           // status 404 (no search results) will be handled in UI.
           if (!error.toString().includes('404')) {
             this.flashError(error);
           }
         });
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
