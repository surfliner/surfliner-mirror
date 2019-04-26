import { shallowMount } from '@vue/test-utils'
import Edit from '@/components/Edit'

describe('Edit.vue', () => {
  const $route = {
    path: '/',
    component: Edit,
    params: { 
      id: 'a_fade_id',
    },
  };

  const wrapper = shallowMount(Edit, {
    mocks: { $route },
  });

  wrapper.vm.item = { 'pref_label':'PrefLabel',
                      'alternate_label':'An alternate Label',
                      'id':'a_fade_id' };

  it('renders title for pref_label', () => {
    expect(wrapper.find('caption span').text()).toMatch(/PrefLabel/)
  })

  it('renders input for pref_label', () => {
    expect(wrapper.find('[name="pref_label"]').element.value)
      .toEqual('PrefLabel')
  })

  it('renders input for alternate_label', () => {
    expect(wrapper.find('[name="alternate_label"]').element.value)
      .toEqual('An alternate Label')
    expect(wrapper.find('#btnUpdate').exists()).toBe(true)
  })

  it('renders the submit button', () => {
    expect(wrapper.find('#btnUpdate').exists()).toBe(true)
    expect(wrapper.find('#btnUpdate').text()).toEqual('Update')
  })
})
