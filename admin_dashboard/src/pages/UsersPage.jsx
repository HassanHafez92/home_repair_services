import { useState } from 'react';

const users = [
  { id: 1, name: 'محمد عبدالله', phone: '+20 1xx xxx xxxx', type: 'عميل', status: 'نشط', jobs: 12, joined: '٢٠٢٦/١/١٥' },
  { id: 2, name: 'أحمد محمد', phone: '+20 1xx xxx xxxx', type: 'فني', status: 'نشط', jobs: 87, joined: '٢٠٢٥/١١/٣' },
  { id: 3, name: 'سارة أحمد', phone: '+20 1xx xxx xxxx', type: 'عميل', status: 'نشط', jobs: 5, joined: '٢٠٢٦/٢/٢٠' },
  { id: 4, name: 'يوسف علي', phone: '+20 1xx xxx xxxx', type: 'فني', status: 'معلق', jobs: 34, joined: '٢٠٢٥/١٢/١' },
  { id: 5, name: 'فاطمة سمير', phone: '+20 1xx xxx xxxx', type: 'عميل', status: 'محظور', jobs: 2, joined: '٢٠٢٦/١/٢٨' },
  { id: 6, name: 'حسن محمود', phone: '+20 1xx xxx xxxx', type: 'فني', status: 'نشط', jobs: 62, joined: '٢٠٢٥/١٠/١٥' },
];

export default function UsersPage() {
  const [filter, setFilter] = useState('all');

  const filtered = filter === 'all'
    ? users
    : users.filter(u => u.type === (filter === 'customer' ? 'عميل' : 'فني'));

  return (
    <>
      <div className="topbar">
        <h1>إدارة المستخدمين</h1>
        <div className="topbar-actions">
          <div className="search-box">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ADB5BD" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input placeholder="بحث بالاسم أو الهاتف..." />
          </div>
        </div>
      </div>

      <div className="page-content">
        {/* Filter tabs */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
          {[
            { id: 'all', label: 'الكل' },
            { id: 'customer', label: 'العملاء' },
            { id: 'tech', label: 'الفنيين' },
          ].map(tab => (
            <button
              key={tab.id}
              className={`btn ${filter === tab.id ? 'btn-primary' : 'btn-outline'}`}
              onClick={() => setFilter(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>

        <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
          <div className="stat-card">
            <div className="stat-value">٢,٤٥٠</div>
            <div className="stat-label">إجمالي العملاء</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">١٨٥</div>
            <div className="stat-label">فنيين معتمدين</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">٢٤</div>
            <div className="stat-label">طلبات KYC معلقة</div>
          </div>
        </div>

        <div className="table-card">
          <div className="table-header">
            <h3>قائمة المستخدمين</h3>
            <button className="btn btn-primary">+ إضافة مستخدم</button>
          </div>
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>الاسم</th>
                <th>الهاتف</th>
                <th>النوع</th>
                <th>الحالة</th>
                <th>الطلبات</th>
                <th>تاريخ الانضمام</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(user => (
                <tr key={user.id}>
                  <td>{user.id}</td>
                  <td style={{ fontWeight: 600 }}>{user.name}</td>
                  <td style={{ direction: 'ltr', textAlign: 'right' }}>{user.phone}</td>
                  <td>
                    <span className={`badge ${user.type === 'فني' ? 'badge-blue' : 'badge-green'}`}>
                      {user.type}
                    </span>
                  </td>
                  <td>
                    <span className={`badge ${
                      user.status === 'نشط' ? 'badge-green' :
                      user.status === 'معلق' ? 'badge-yellow' : 'badge-red'
                    }`}>
                      {user.status}
                    </span>
                  </td>
                  <td>{user.jobs}</td>
                  <td>{user.joined}</td>
                  <td>
                    <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: 12 }}>
                      عرض
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
