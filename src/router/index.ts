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
          component: () => import('../views/admin/ManageBooks.vue'),
          meta: { requiresAdmin: true }
        },
        {
          path: 'admin/users',
          name: 'admin-users',
          component: () => import('../views/admin/Users.vue'),
          meta: { requiresAdmin: true }
        },
        {
          path: 'admin/reports',
          name: 'admin-reports',
          component: () => import('../views/admin/Reports.vue'),
          meta: { requiresAdmin: true }
        },
        {
          path: 'admin/activity',
          name: 'admin-activity',
          component: () => import('../views/admin/Activity.vue'),
          meta: { requiresAdmin: true }
        }
      ]
    },
    {
      path: '/read/:id',
      name: 'read',
      component: () => import('../views/reader/ReaderWrapper.vue')
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/auth/Login.vue'),
      meta: { public: true }
    },
    {
      path: '/reset-password',
      name: 'reset-password',
      component: () => import('../views/auth/ResetPassword.vue'),
      meta: { public: true }
    }
  ]
})

router.beforeEach(async (to, _from, next) => {
  const { data: { session } } = await supabase.auth.getSession()
  const isAuthenticated = !!session

  // Always allow public routes
  if (to.meta.public) {
    // If already logged in and trying to go to /login, redirect to dashboard
    if (to.name === 'login' && isAuthenticated) {
      return next({ name: 'dashboard' })
    }
    return next()
  }

  // Require authentication for everything else
  if (!isAuthenticated) {
    return next({ name: 'login' })
  }

  // Admin-only routes
  if (to.meta.requiresAdmin) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', session?.user.id)
      .single()

    if (profile?.role === 'admin') {
      return next()
    } else {
      return next({ name: 'dashboard' })
    }
  }

  next()
})

export default router
