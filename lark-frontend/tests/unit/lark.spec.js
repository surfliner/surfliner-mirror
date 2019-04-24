import { shallowMount } from '@vue/test-utils'
import Lark from '@/components/Lark.vue'

describe('Lark.vue', () => {
  const wrapper = shallowMount(Lark)

  it('renders app title and search form', () => {
    expect(wrapper.find('h1').text()).toMatch('Lark Authority')

    expect(wrapper.find('[name="search"]').exists()).toBe(true)
    expect(wrapper.find('#btnSearch').exists()).toBe(true)
  })

  it('authoritiesCount should evaluate correctly', () => {
     wrapper.setData({
      searchText: '',
      page: 'search',
      authorities: [{ 'pref_label':['PrefLabel'], 'id':'a_fade_id' }],
      item: { }
    });
    expect(wrapper.vm.authoritiesCount).toEqual(1);
  })

  it('displayPage should evaluate correctly', () => {
     wrapper.setData({
      searchText: '',
      page: 'item',
      authorities: [{ 'pref_label':['PrefLabel'], 'id':'a_fade_id' }],
      item: { 'pref_label':'PrefLabel', 'id':'a_fade_id' }
    });
    expect(wrapper.vm.displayPage).toMatch('item')
  })

  it('display search results page', () => {
     wrapper.setData({
      searchText: '',
      page: 'search',
      authorities: [{ 'pref_label':['PrefLabel'], 'id':'a_fade_id' }],
      item: { }
    });
    expect(wrapper.find('p').text()).toMatch('Results found: 1')
    expect(wrapper.find('a').text()).toMatch(/PrefLabel/)
  })

  it('display item page', () => {
     wrapper.setData({
      searchText: '',
      page: 'item',
      authorities: [{ 'pref_label':['PrefLabel'], 'id':'a_fade_id' }],
      item: { 'pref_label':'PrefLabel', 'id':'a_fade_id' }
    });
    expect(wrapper.find('caption span').text()).toMatch(/PrefLabel/)
    expect(wrapper.find('caption button').exists()).toBe(true)
  })

  it('show edit page', () => {
     wrapper.setData({
      searchText: '',
      page: 'edit',
      authorities: [],
      item: { 'pref_label':'PrefLabel',
              'alternate_label':'An alternate Label',
              'id':'a_fade_id' }
    });
    expect(wrapper.find('caption span').text()).toMatch(/PrefLabel/)

    expect(wrapper.find('[name="pref_label"]').element.value)
      .toEqual('PrefLabel')
    expect(wrapper.find('[name="alternate_label"]').element.value)
      .toEqual('An alternate Label')
    expect(wrapper.find('#btnUpdate').exists()).toBe(true)
  })

  it('shows the form for new authority creation', () => {
     wrapper.setData({
      searchText: '',
      page: 'new',
      authorities: [],
      item: { 'pref_label':[], 'alternate_label':[] }
    });
    expect(wrapper.find('caption span').text()).toMatch('Create New Authority')

    expect(wrapper.find('[name="pref_label"]').exists()).toBe(true)
    expect(wrapper.find('[name="alternate_label"]').exists()).toBe(true)
    expect(wrapper.find('#btnCreate').exists()).toBe(true)
  })
})
