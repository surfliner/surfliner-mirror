<template>
  <div id="app">
    <Lark/>
  </div>
</template>

<script>
  import Lark from './components/Lark.vue'

  export default {
    name: 'app',
    components: {
      Lark
    }
  }
</script>

<style>
  @import './assets/css/lark.css';
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }
</style>
