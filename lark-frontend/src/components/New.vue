<template>
  <div id="new" align="center">
    <Lark/>

    <div class="ui-group">
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
    <div class="btn-group">
      <button type="button" @click="cancel()" id="btnCancel">Cancel</button>
      <button type="button" v-on:click="createAuthority()" id="btnCreate">Create</button>
    </div>
  </div>
</template>

<script src='../assets/scripts/new.js'/>

