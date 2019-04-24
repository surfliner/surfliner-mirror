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
                <input type="text" class="field" :name="key" :value="value" @input="updateField(key, $event)">
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div><button type="button" v-on:click="createAuthority()" id="btnCreate">Create</button></div>
    </div>

    <div v-if="displayPage === 'edit'">
      <div align="center">
        <table>
          <caption><span>Edit {{ fieldValue(item.pref_label) }}</span></caption>
          <tbody>
            <tr v-for="(value, key) of item" :key="key">
              <td v-if="key != 'id'">
                <label :for="key">{{ nomalizeLabel(key) }}</label>
                <input type="text" class="field" :name="key" :value="value" @input="updateField(key, $event)">
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div><button type="button" v-on:click="updateAuthority()" id="btnUpdate">Update</button></div>
    </div>

    <div v-if="displayPage === 'item' && item.id">
      <div align="center">
        <table>
          <caption>
            <span>{{ fieldValue(item.pref_label) }}</span>
            <button v-on:click="editAuthority()" id="btnEdit">Edit</button>
          </caption>
          <thead>
            <tr><th class="attribute" nowrap>Attribute Name</th><th>Values</th></tr>
          </thead>
          <tbody>
          <tr v-for="(value, key) of displayAttributes" :key="key">
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

<script src="../assets/scripts/lark.js"/>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
