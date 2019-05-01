<template>
  <div id="record" align="center">
    <Lark/>

    <div class="ui-group">
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
            <td class="attr-name">{{ nomalizeLabel(key) }}</td><td class="attr-value">{{ fieldValue(value) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="btn-group">
      <button type="button" @click="cancel()" id="btnBack">&lt;&lt; Back</button>
    </div>
  </div>
</template>

<script src='../assets/scripts/record.js'/>

