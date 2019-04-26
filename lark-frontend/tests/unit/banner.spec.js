import { shallowMount } from '@vue/test-utils'
import Banner from '@/components/Banner'

describe('Banner.vue', () => {
  const wrapper = shallowMount(Banner);

  it('renders app title', () => {
    expect(wrapper.find('h1').text()).toMatch('Lark Authority')
  })
})
