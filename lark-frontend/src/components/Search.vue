<template>
  <div id="search" align="center">
    <Lark/>

    <div class="ui-group" v-if="authoritiesCount > 0">
      <p v-if="authorities">Results found: {{ authoritiesCount }}</p>
      <ul v-for="auth in authorities" :key="auth.id">
        <li>
          <a v-on:click="displayItem(auth.id)">{{ auth.pref_label[0] }}</a>
        </li>
      </ul>
    </div>
    <div class="ui-group" v-else>
      <p v-if="authorities">No results found.</p>
    </div>
  </div>

</template>

<script src="../assets/scripts/search.js"/>
