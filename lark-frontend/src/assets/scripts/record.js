import mixin from '@/assets/scripts/app.js'
import Lark from '@/components/Lark'

export default {
  mixins: [mixin],
  name: 'Record',
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
    loadRecord(id) {
      this.fetchData(this.$lark_url + id);

      // flash the message as info if there's any
      if (this.$route.query && this.$route.query.message) {
        this.flash(this.$route.query.message, 'info', { timeout: 3000 });
      }
    },
    editAuthority() {
      this.$router.push({ path: `/${this.item.id}/edit`});
    },
  }
}