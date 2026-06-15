import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../services/supabase'

import EmployeeLayout from '../components/layout/EmployeeLayout.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      redirect: '/dashboard'
    },
    {
      path: '/',
      component: EmployeeLayout,
      children: [
        {
          path: 'dashboard',
          name: 'dashboard',
          component: () => import('../views/employee/Dashboard.vue')
        },
        {
          path: 'library',
          name: 'library',
          component: () => import('../views/employee/Library.vue')
        },
        {
          path: 'admin/books',
          name: 'admin-books',
          component: () => import('../views/admin/ManageBooks.vue')
        }
      ]
    },
    {
      path: '/read/:id',
      name: 'read',
      component: () => import('../views/reader/Read.vue')
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/auth/Login.vue')
    }
  ]
})

router.beforeEach(async (to, _from, next) => {
  const { data: { session } } = await supabase.auth.getSession()
  
  const isAuthenticated = !!session
  
  if (to.name !== 'login' && !isAuthenticated) {
    next({ name: 'login' })
  } else if (to.name === 'login' && isAuthenticated) {
    next({ name: 'dashboard' })
  } else {
    next()
  }
})

export default router
