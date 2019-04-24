<template>
  <div class="lark" align="center">
    <div  style="width:500px">
    <h1>Lark Authority</h1>
    <div align="left"><button v-on:click="newAuthority()">New Authority</button></div>
    <div align="left">
      <input class="search" type="text" name="search" v-model="searchText" placeholder="PrefLabel">
      <button v-on:click="getAuthorities()" id="btnSearch">Search</button>
    </div>

    <hr>
    <div v-if="displayPage === 'new'">
      <div align="center">
        <table>
          <caption><span nowrap>Create New Authority</span></caption>
          <tbody>
            <tr v-for="(value, key) of item" :key="key">
              <td>
                <label :for="key">{{ nomalizeLabel(key) }}</label>
                <input type="text" class="field" :name="key" :value="value" @input="updateField(key, $event)" :placeholder="key">
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div><button type="button" v-on:click="createAuthority()" id="btnCreate">Submit</button></div>
    </div>

    <div v-if="displayPage === 'edit'">
      <div align="center">
        <table>
          <caption><span>Edit {{ fieldValue(item.pref_label) }}</span></caption>
          <tbody>
            <tr v-for="(value, key) of item" :key="key">
              <td v-if="key != 'id'">
                <label :for="key">{{ nomalizeLabel(key) }}</label>
                <input type="text" class="field" :name="key" :value="value" @input="updateField(key, $event)" :placeholder="key">
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div><button type="button" v-on:click="updateAuthority()" id="btnUpdate">Submit</button></div>
    </div>

    <div v-if="displayPage === 'item' && item.id">
      <div align="center">
        <table>
          <caption>
            <span>Authority {{ fieldValue(item.pref_label) }}</span>
            <button v-on:click="editAuthority()" id="btnEdit">Edit</button>
          </caption>
          <thead>
            <tr><th class="attribute" nowrap>Attribute Name</th><th>Values</th></tr>
          </thead>
          <tbody>
          <tr v-for="(value, key) of item" :key="key" v-if="key != 'id'">
            <td>{{ nomalizeLabel(key) }}</td><td>{{ fieldValue(value) }}</td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-else-if="displayPage === 'search'">
      <div v-if="authoritiesCount > 0">
        <p v-if="authorities">Results found: {{ authoritiesCount }}</p>
        <ul v-for="auth in authorities" :key="auth.id">
          <li>
            <a v-on:click="displayItem(auth.id)">{{ auth.pref_label[0] }}</a>
          </li>
        </ul>
      </div>
      <div v-else>
        <p v-if="authorities">No results found.</p>
      </div>
    </div>
    </div>
  </div>
</template>

<script>
const status = response => {
  if (response.status >= 200 && response.status < 300) {
    return Promise.resolve(response)
  }
  return Promise.reject(new Error(response.statusText))
}

const lark_url = 'http://localhost:9292/'
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
    authoritiesCount () {
      return this.authorities ? this.authorities.length : 0;
    },
    displayPage () {
      return this.page;
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
