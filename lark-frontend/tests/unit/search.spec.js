import { shallowMount } from '@vue/test-utils'
import Search from '@/components/Search'

describe('Search.vue', () => {
  const $route = {
    path: '/search',
    component: Search,
    query: { 
      pref_label: 'PrefLabel',
    },
  };

  const wrapper = shallowMount(Search, {
    mocks: { $route },
  });

  wrapper.vm.authorities = [{ 'pref_label':['PrefLabel'], 'id':'a_fade_id' }];

  it('authoritiesCount should evaluate correctly', () => {
    expect(wrapper.vm.authoritiesCount).toEqual(1);
  })

  it('renders the search results found', () => {
    expect(wrapper.find('p').text()).toMatch('Results found: 1')
  })

  it('renders the link for the record', () => {
    expect(wrapper.find('a').text()).toMatch(/PrefLabel/)
  })
})
