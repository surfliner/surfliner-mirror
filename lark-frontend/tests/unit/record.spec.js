import { shallowMount } from '@vue/test-utils'
import Record from '@/components/Record'

describe('Record.vue', () => {
  const $route = {
    path: '/',
    component: Record,
    params: { 
      id: 'a_fade_id',
    },
  };

  const wrapper = shallowMount(Record, {
    mocks: { $route },
  });

  wrapper.vm.item = { 'pref_label':'PrefLabel', 'id':'a_fade_id' };

  it('renders the caption', () => {
    expect(wrapper.find('caption span').text()).toMatch(/PrefLabel/)
  })

  it('renders pred_label', () => {
    expect(wrapper.find('.attr-name').text()).toEqual('Pref label')
    expect(wrapper.find('.attr-value').text()).toEqual('PrefLabel')
  })

  it('renders the edit button', () => {
    expect(wrapper.find('caption button').exists()).toBe(true)
  })
})
