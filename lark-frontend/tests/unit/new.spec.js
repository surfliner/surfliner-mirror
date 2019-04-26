import { shallowMount } from '@vue/test-utils'
import New from '@/components/New'

describe('Edit.vue', () => {
  const $route = {
    path: '/',
    component: New,
  };

  const wrapper = shallowMount(New, {
    mocks: { $route },
  });

  wrapper.vm.item = { 'pref_label':[], 'alternate_label':[] };

  it('renders caption for new authority creation', () => {
    expect(wrapper.find('caption span').text()).toMatch('Create New Authority')
  })
  
  it('renders input for pref_label', () => {
    expect(wrapper.find('[name="pref_label"]').exists()).toBe(true)
  })

  it('renders input for alternate_label', () => {
    expect(wrapper.find('[name="alternate_label"]').exists()).toBe(true)
  })

  it('renders the submit button', () => {
    expect(wrapper.find('#btnCreate').exists()).toBe(true)
    expect(wrapper.find('#btnCreate').text()).toEqual('Create')
  })
})
