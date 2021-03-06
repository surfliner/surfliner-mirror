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
    fetchData(url) {
      this.$flashStorage.destroyAll();
      this.axios.get(url, { mode: "cors" })
        .then(this.$status)
        .then(response => { this.item = response.data; })
        .catch(error => { this.flashError(error); });
    },
   /**
    * Cancel: router back
    **/
    cancel() {
      this.$router.go(-1);
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
