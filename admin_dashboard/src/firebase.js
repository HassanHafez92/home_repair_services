// Firebase configuration for Fixawy Admin Dashboard
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  // TODO: Replace with your Firebase project config
  // Run: firebase apps:sdkconfig web
  apiKey: "YOUR_API_KEY",
  authDomain: "fixawy-app-production.firebaseapp.com",
  projectId: "fixawy-app-production",
  storageBucket: "fixawy-app-production.firebasestorage.app",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID",
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export default app;
