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
        "identifier": [],
        "literal_form": [],
        "label_source": [],
        "campus": [],
        "annotation": []
      }
    }
  },
  components: {
    Lark
  },
  methods: {
    createAuthority() {
      this.axios.post(this.$lark_url, this.item, this.$cors_headers)
        .then(this.$status)
        .then(response => { 
              this.$router.push({ path: `/${response.data.id}`,
                                  query: { message: this.$message.SUCCESS } }) })
        .catch(error => { this.flashError(this.$message.FALIED + ' ' + error) });
    }
  }
}
