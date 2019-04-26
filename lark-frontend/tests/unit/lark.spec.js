import { shallowMount } from '@vue/test-utils'
import Lark from '@/components/Lark'
import Banner from '@/components/Banner'

describe('Lark.vue', () => {
  const wrapper = shallowMount(Lark, {
    stubs: {
      'Banner': Banner,
    }
  });

  it('renders banner', () => {
    expect(wrapper.find(Banner).exists()).toBe(true)
  })

  it('renders banner text', () => {
    expect(wrapper.find('h1').text()).toMatch('Lark Authority')
  })

  it('renders the search form', () => {
    expect(wrapper.find('[name="search"]').exists()).toBe(true)
    expect(wrapper.find('#btnSearch').exists()).toBe(true)
  })
})
