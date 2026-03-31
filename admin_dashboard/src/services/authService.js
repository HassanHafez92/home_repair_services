// Authentication service for Admin Dashboard
import { auth } from '../firebase';
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'firebase/auth';

/**
 * Sign in with admin email and password
 */
export async function loginAdmin(email, password) {
  const credential = await signInWithEmailAndPassword(auth, email, password);

  // Verify admin role via custom claims
  const idTokenResult = await credential.user.getIdTokenResult(true);
  if (idTokenResult.claims.role !== 'admin') {
    await signOut(auth);
    throw new Error('ليس لديك صلاحيات الأدمن');
  }

  return credential.user;
}

/**
 * Sign out admin
 */
export async function logoutAdmin() {
  await signOut(auth);
}

/**
 * Listen to auth state changes
 */
export function onAuthChange(callback) {
  return onAuthStateChanged(auth, async (user) => {
    if (user) {
      const tokenResult = await user.getIdTokenResult();
      const isAdmin = tokenResult.claims.role === 'admin';
      callback(isAdmin ? user : null);
    } else {
      callback(null);
    }
  });
}

/**
 * Get current admin user
 */
export function getCurrentAdmin() {
  return auth.currentUser;
}
