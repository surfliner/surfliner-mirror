<template>
  <div id="lark" align="center">
    <Banner/>

    <div class="ui-group">
      <div align="left"><button v-on:click="newAuthority()">New Authority</button></div>
      <div align="left">
        <input class="search-box" type="text" name="search" v-model="searchText" placeholder="PrefLabel">
        <button v-on:click="search()" id="btnSearch">Search</button>
      </div>

      <hr>
    </div>

    <flash-message class="flash"></flash-message>
  </div>
</template>

<script src="../assets/scripts/lark.js"/>
