import Vue from 'vue'
import VueRouter from 'vue-router'
import Lark from '@/components/Lark'
import Search from '@/components/Search'
import New from '@/components/New'
import Record from '@/components/Record'
import Edit from '@/components/Edit'

Vue.use(VueRouter)

export default new VueRouter({
  routes: [
    {
      path: '/',
      name: 'Lark',
      component: Lark
    },
    {
      path: '/search',
      name: 'Search',
      component: Search
    },
    {
      path: '/new',
      name: 'New',
      component: New
    },
    {
      path: '/:id',
      name: 'Record',
      component: Record
    },
    {
      path: '/:id/edit',
      name: 'edit',
      component: Edit
    }
  ]
})
