<template>
  <div id='edit' align="center">
    <Lark/>

    <div class="ui-group">
      <table>
        <caption><span>Edit {{ fieldValue(item.pref_label) }}</span></caption>
        <tbody>
          <tr v-for="(value, key) of displayAttributes" :key="key">
            <td v-if="key != 'id'">
              <label :for="key">{{ nomalizeLabel(key) }}</label>
              <input type="text" class="field" :name="key" :value="value" @input="updateField(key, $event)">
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="btn-group">
      <button type="button" @click="cancel()" id="btnCancel">Cancel</button>
      <button type="button" v-on:click="updateAuthority()" id="btnUpdate">Update</button>
    </div>
  </div>
</template>

<script src='../assets/scripts/edit.js'/>

