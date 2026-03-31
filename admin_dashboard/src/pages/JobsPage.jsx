const jobs = [
  { id: 'JOB-1042', customer: 'محمد عبدالله', service: 'سباكة', tech: 'أحمد محمد', status: 'مكتمل', amount: '٣٥٠', date: '٣١/٣/٢٠٢٦', statusClass: 'badge-green' },
  { id: 'JOB-1041', customer: 'سارة أحمد', service: 'كهرباء', tech: 'يوسف علي', status: 'جاري', amount: '٢٧٥', date: '٣١/٣/٢٠٢٦', statusClass: 'badge-blue' },
  { id: 'JOB-1040', customer: 'علي حسن', service: 'تكييف', tech: 'حسن محمود', status: 'مكتمل', amount: '٥٢٥', date: '٣٠/٣/٢٠٢٦', statusClass: 'badge-green' },
  { id: 'JOB-1039', customer: 'فاطمة سمير', service: 'سباكة', tech: 'أحمد محمد', status: 'نزاع', amount: '١٨٠', date: '٣٠/٣/٢٠٢٦', statusClass: 'badge-red' },
  { id: 'JOB-1038', customer: 'مريم خالد', service: 'نجارة', tech: 'عمر حسين', status: 'قيد المراجعة', amount: '٤٠٠', date: '٢٩/٣/٢٠٢٦', statusClass: 'badge-yellow' },
  { id: 'JOB-1037', customer: 'أمير سعيد', service: 'دهان', tech: 'محمد حسن', status: 'ملغي', amount: '٢٠٠', date: '٢٩/٣/٢٠٢٦', statusClass: 'badge-red' },
  { id: 'JOB-1036', customer: 'نور الدين', service: 'كهرباء', tech: 'يوسف علي', status: 'مكتمل', amount: '٣٨٠', date: '٢٨/٣/٢٠٢٦', statusClass: 'badge-green' },
];

export default function JobsPage() {
  return (
    <>
      <div className="topbar">
        <h1>إدارة الطلبات</h1>
        <div className="topbar-actions">
          <div className="search-box">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ADB5BD" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input placeholder="بحث برقم الطلب..." />
          </div>
          <button className="btn btn-primary">تصدير</button>
        </div>
      </div>

      <div className="page-content">
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#E0F5F5', color: '#0D7377' }}>📋</div>
            <div className="stat-value">١,٠٤٢</div>
            <div className="stat-label">طلبات هذا الشهر</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#E8F8F0', color: '#2CB67D' }}>✓</div>
            <div className="stat-value">٨٥٪</div>
            <div className="stat-label">نسبة الإكمال</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#FFF3D6', color: '#E8A838' }}>⏱</div>
            <div className="stat-value">٤٢ د</div>
            <div className="stat-label">متوسط الاستجابة</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#FFE8E5', color: '#E85D4A' }}>⚠️</div>
            <div className="stat-value">٣</div>
            <div className="stat-label">نزاعات مفتوحة</div>
          </div>
        </div>

        <div className="table-card">
          <div className="table-header">
            <h3>جميع الطلبات</h3>
          </div>
          <table>
            <thead>
              <tr>
                <th>رقم الطلب</th>
                <th>العميل</th>
                <th>الخدمة</th>
                <th>الفني</th>
                <th>الحالة</th>
                <th>المبلغ</th>
                <th>التاريخ</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {jobs.map(job => (
                <tr key={job.id}>
                  <td style={{ fontWeight: 600 }}>{job.id}</td>
                  <td>{job.customer}</td>
                  <td>{job.service}</td>
                  <td>{job.tech}</td>
                  <td><span className={`badge ${job.statusClass}`}>{job.status}</span></td>
                  <td style={{ fontWeight: 600 }}>{job.amount} ج.م</td>
                  <td>{job.date}</td>
                  <td>
                    <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: 12 }}>
                      تفاصيل
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
