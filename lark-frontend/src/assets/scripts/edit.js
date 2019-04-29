import mixin from '@/assets/scripts/app.js'
import Lark from '@/components/Lark'

export default {
  mixins: [mixin],
  name: 'Edit',
  data: function() {
      return {
        item: {}
    }
  },
  components: {
    Lark
  },
  created() {
    this.loadRecord(this.$route.params.id)
  },
  watch: {
    '$route': 'loadRecord'
  },
  methods: {
    updateAuthority() {
      this.axios.put(this.$lark_url + this.item.id, this.item, this.$cors_headers)
        .then(this.$status)
        .then(this.$router.push({ path: `/${this.item.id}` }))
        .catch(error => { console.log('Request failed', error) });
    },
    loadRecord(id) {
      this.fetchData(this.$lark_url + id);
    },
  }
}