export default {
  methods: {
    fieldValue(value)
    {
      return value instanceof Array ? value[0] : value;
    },
    nomalizeLabel(value) 
    {
      var v = value.replace('_', ' ')
      return v.charAt(0).toUpperCase() + v.slice(1);
    },
    updateField(fieldName, e) {
      this.$set(this.item, fieldName, e.target.value);
      this.$emit('input', e.target.value)
    },
    async fetchRecord(id) {
      fetch(this.$lark_url + id, { mode: "cors" })
        .then(this.$status)
        .then(this.$json)
        .then(data => { this.item = data; })
        .catch(error => { console.log('Request failed', error) });
    }
  },
  computed: {
    displayAttributes() {
      var dup = JSON.parse(JSON.stringify(this.item));
      delete dup['id']
      return dup;
    }
  }
};