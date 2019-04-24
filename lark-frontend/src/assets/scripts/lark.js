const status = response => {
  if (response.status >= 200 && response.status < 300) {
    return Promise.resolve(response)
  }
  return Promise.reject(new Error(response.statusText))
}

const lark_url = process.env.VUE_APP_ROOT_API
const json = response => response.json()

export default {
  name: 'Lark',
  data: function() {
    return {
      searchText: '',
      page: '',
      authorities: [],
      item: {}
    }
  },
  methods: {
    async getAuthorities() {
      this.authorities = [];
      fetch(lark_url + 'search?pref_label=' + this.searchText, { mode: 'cors' })
        .then(status)
        .then(json)
        .then(data => this.authorities = data)
        .then(this.page = 'search')
        .catch(error => { console.log('Request failed', error) });
    },
    async displayItem(id) {
      fetch(lark_url + id, { mode: "cors" })
        .then(status)
        .then(json)
        .then(data => this.item = data)
        .then(this.page = 'item')
        .catch(error => { console.log('Request failed', error) });
    },
    newAuthority() {
      this.page = 'new';
      this.item = {
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
    },
    async createAuthority() {
      this.axios.post(lark_url, this.item, { mode: 'cors', headers: { 'Content-Type': 'application/json' } })
        .then(status)
        .then(response => this.item = response.data)
        .then(this.page = 'item')
        .catch(error => { console.log('Request failed', error) });
      
    },
    editAuthority() {
      this.page = 'edit';
      this.pref_label = this.item.pref_label[0];
      this.alternate_label = this.item.alternate_label[0];
    },
    async updateAuthority() {
      this.axios.put(lark_url + this.item.id, this.item, { mode: 'cors', headers: { 'Content-Type': 'application/json' } })
        .then(status)
        .then(this.page = 'item')
        .catch(error => { console.log('Request failed', error) });
    },
    updateField(fieldName, e) {
      this.$set(this.item, fieldName, e.target.value);
      this.$emit('input', e.target.value)
    },
    fieldValue(value)
    {
      return value instanceof Array ? value[0] : value;
    },
    nomalizeLabel(value) 
    {
      var v = value.replace('_', ' ')
      return v.charAt(0).toUpperCase() + v.slice(1);
    }
  },
  computed: {
    authoritiesCount() {
      return this.authorities ? this.authorities.length : 0;
    },
    displayPage() {
      return this.page;
    },
    displayAttributes() {
      var dup = JSON.parse(JSON.stringify(this.item));
      delete dup['id']
      return dup;
    }
  }
}