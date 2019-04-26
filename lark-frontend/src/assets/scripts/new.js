import mixin from '@/assets/scripts/app.js'
import Lark from '@/components/Lark'

export default {
  mixins: [mixin],
  name: 'New',
  data: function() {
      return {
        item: {
        "pref_label": [],
        "alternate_label": [],
        "hidden_label": [],
        "exact_match": [],
        "close_match": [],
        "note": [],
        "scope_note": [],
        "editorial_note": [],
        "history_note": [],
        "definition": [],
        "identifier": []
      }
    }
  },
  components: {
    Lark
  },
  methods: {
    async createAuthority() {
      this.axios.post(this.$lark_url, this.item, this.$cors_headers)
        .then(this.$status)
        .then(response => {this.item = response.data; this.$router.push({ path: `/${this.item.id}`});})
        .catch(error => { console.log('Request failed', error) });
      
    }
  }
}