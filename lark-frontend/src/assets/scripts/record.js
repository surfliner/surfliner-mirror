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
      this.fetchRecord(id);
    },
    editAuthority() {
      this.$router.push({ path: `/${this.item.id}/edit`});
    },
  }
}