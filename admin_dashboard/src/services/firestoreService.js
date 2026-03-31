// Firestore service for Admin Dashboard
import { db } from '../firebase';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  where,
  orderBy,
  limit,
  onSnapshot,
  updateDoc,
  Timestamp,
} from 'firebase/firestore';

// ─── Dashboard Stats ──────────────────────────────────

export async function getDashboardStats() {
  const usersSnap = await getDocs(collection(db, 'users'));
  const techsSnap = await getDocs(collection(db, 'technicians'));
  const jobsSnap = await getDocs(collection(db, 'jobs'));

  const completedJobs = jobsSnap.docs.filter(
    (d) => d.data().status === 'completed'
  );
  const totalRevenue = completedJobs.reduce(
    (sum, d) => sum + (d.data().platformFee || 0),
    0
  );

  return {
    totalUsers: usersSnap.size,
    totalTechnicians: techsSnap.size,
    totalJobs: jobsSnap.size,
    completedJobs: completedJobs.length,
    totalRevenue,
    activeJobs: jobsSnap.docs.filter(
      (d) => !['completed', 'cancelled'].includes(d.data().status)
    ).length,
  };
}

// ─── Users ────────────────────────────────────────────

export function streamUsers(callback) {
  const q = query(collection(db, 'users'), orderBy('createdAt', 'desc'), limit(100));
  return onSnapshot(q, (snap) => {
    const users = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    callback(users);
  });
}

export function streamTechnicians(callback) {
  const q = query(collection(db, 'technicians'), orderBy('createdAt', 'desc'), limit(100));
  return onSnapshot(q, (snap) => {
    const techs = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    callback(techs);
  });
}

export async function updateUserStatus(userId, disabled) {
  await updateDoc(doc(db, 'users', userId), { disabled });
}

export async function approveTechnicianKyc(techId) {
  await updateDoc(doc(db, 'technicians', techId), {
    kycStatus: 'approved',
    kycApprovedAt: Timestamp.now(),
  });
}

export async function rejectTechnicianKyc(techId, reason) {
  await updateDoc(doc(db, 'technicians', techId), {
    kycStatus: 'rejected',
    kycRejectionReason: reason,
    kycRejectedAt: Timestamp.now(),
  });
}

// ─── Jobs ─────────────────────────────────────────────

export function streamJobs(callback, statusFilter = null) {
  let q;
  if (statusFilter) {
    q = query(
      collection(db, 'jobs'),
      where('status', '==', statusFilter),
      orderBy('createdAt', 'desc'),
      limit(100)
    );
  } else {
    q = query(collection(db, 'jobs'), orderBy('createdAt', 'desc'), limit(100));
  }

  return onSnapshot(q, (snap) => {
    const jobs = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    callback(jobs);
  });
}

export async function getJobDetails(jobId) {
  const docSnap = await getDoc(doc(db, 'jobs', jobId));
  return docSnap.exists() ? { id: docSnap.id, ...docSnap.data() } : null;
}

// ─── Pricing ──────────────────────────────────────────

export function streamPricing(callback) {
  return onSnapshot(collection(db, 'pricing'), (snap) => {
    const pricing = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    callback(pricing);
  });
}

export async function updatePricing(categoryId, data) {
  await updateDoc(doc(db, 'pricing', categoryId), {
    ...data,
    updatedAt: Timestamp.now(),
  });
}

// ─── Revenue Analytics ────────────────────────────────

export async function getRevenueByMonth() {
  const jobsSnap = await getDocs(
    query(collection(db, 'jobs'), where('status', '==', 'completed'))
  );

  const monthlyRevenue = {};
  jobsSnap.docs.forEach((d) => {
    const data = d.data();
    const date = data.completedAt?.toDate() || new Date();
    const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
    monthlyRevenue[key] = (monthlyRevenue[key] || 0) + (data.platformFee || 0);
  });

  return Object.entries(monthlyRevenue)
    .map(([month, revenue]) => ({ month, revenue }))
    .sort((a, b) => a.month.localeCompare(b.month));
}

// ─── Disputes ─────────────────────────────────────────

export function streamDisputes(callback) {
  const q = query(
    collection(db, 'disputes'),
    orderBy('createdAt', 'desc'),
    limit(50)
  );
  return onSnapshot(q, (snap) => {
    const disputes = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    callback(disputes);
  });
}

export async function resolveDispute(disputeId, resolution) {
  await updateDoc(doc(db, 'disputes', disputeId), {
    status: 'resolved',
    resolution,
    resolvedAt: Timestamp.now(),
  });
}
