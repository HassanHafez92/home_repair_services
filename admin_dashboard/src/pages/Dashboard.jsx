import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

const revenueData = [
  { month: 'يناير', revenue: 12500 },
  { month: 'فبراير', revenue: 18200 },
  { month: 'مارس', revenue: 24800 },
  { month: 'أبريل', revenue: 31200 },
  { month: 'مايو', revenue: 28500 },
  { month: 'يونيو', revenue: 42000 },
];

const categoryData = [
  { name: 'سباكة', value: 35 },
  { name: 'كهرباء', value: 28 },
  { name: 'تكييف', value: 18 },
  { name: 'نجارة', value: 12 },
  { name: 'أخرى', value: 7 },
];

const COLORS = ['#0D7377', '#14A3A8', '#E8A838', '#1B2B4D', '#E85D4A'];

const recentJobs = [
  { id: 'JOB-1042', customer: 'محمد عبدالله', service: 'سباكة', tech: 'أحمد محمد', status: 'مكتمل', amount: '٣٥٠ ج.م', statusClass: 'badge-green' },
  { id: 'JOB-1041', customer: 'سارة أحمد', service: 'كهرباء', tech: 'يوسف علي', status: 'جاري', amount: '٢٧٥ ج.م', statusClass: 'badge-blue' },
  { id: 'JOB-1040', customer: 'علي حسن', service: 'تكييف', tech: 'حسن محمود', status: 'مكتمل', amount: '٥٢٥ ج.م', statusClass: 'badge-green' },
  { id: 'JOB-1039', customer: 'فاطمة سمير', service: 'سباكة', tech: 'أحمد محمد', status: 'نزاع', amount: '١٨٠ ج.م', statusClass: 'badge-red' },
  { id: 'JOB-1038', customer: 'مريم خالد', service: 'نجارة', tech: 'عمر حسين', status: 'قيد المراجعة', amount: '٤٠٠ ج.م', statusClass: 'badge-yellow' },
];

export default function Dashboard() {
  return (
    <>
      <div className="topbar">
        <h1>نظرة عامة</h1>
        <div className="topbar-actions">
          <div className="search-box">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ADB5BD" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input placeholder="بحث..." />
          </div>
          <button className="btn btn-primary">+ تصدير التقرير</button>
        </div>
      </div>

      <div className="page-content">
        {/* Stats */}
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#E0F5F5', color: '#0D7377' }}>👥</div>
            <div className="stat-value">٢,٤٥٠</div>
            <div className="stat-label">إجمالي العملاء</div>
            <div className="stat-change up">↑ ١٢٪ هذا الشهر</div>
          </div>

          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#E8F8F0', color: '#2CB67D' }}>🔧</div>
            <div className="stat-value">١٨٥</div>
            <div className="stat-label">فنيين نشطين</div>
            <div className="stat-change up">↑ ٨٪ هذا الشهر</div>
          </div>

          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#FFF3D6', color: '#E8A838' }}>📋</div>
            <div className="stat-value">٥,٢٣٤</div>
            <div className="stat-label">إجمالي الطلبات</div>
            <div className="stat-change up">↑ ٢٣٪ هذا الشهر</div>
          </div>

          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#FFE8E5', color: '#E85D4A' }}>💰</div>
            <div className="stat-value">١٥٧,٥٠٠</div>
            <div className="stat-label">الإيرادات (ج.م)</div>
            <div className="stat-change up">↑ ١٨٪ هذا الشهر</div>
          </div>
        </div>

        {/* Charts */}
        <div className="charts-row">
          <div className="chart-card">
            <h3>الإيرادات الشهرية</h3>
            <ResponsiveContainer width="100%" height={280}>
              <AreaChart data={revenueData}>
                <defs>
                  <linearGradient id="revenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0D7377" stopOpacity={0.15} />
                    <stop offset="95%" stopColor="#0D7377" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#E2E5EA" />
                <XAxis dataKey="month" tick={{ fontFamily: 'Cairo', fontSize: 12 }} />
                <YAxis tick={{ fontFamily: 'Cairo', fontSize: 12 }} />
                <Tooltip contentStyle={{ fontFamily: 'Cairo', borderRadius: 10, border: '1px solid #E2E5EA' }} />
                <Area type="monotone" dataKey="revenue" stroke="#0D7377" strokeWidth={2.5} fillOpacity={1} fill="url(#revenue)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          <div className="chart-card">
            <h3>توزيع الخدمات</h3>
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie data={categoryData} cx="50%" cy="50%" innerRadius={65} outerRadius={100} paddingAngle={4} dataKey="value">
                  {categoryData.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ fontFamily: 'Cairo', borderRadius: 10 }} />
              </PieChart>
            </ResponsiveContainer>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, justifyContent: 'center' }}>
              {categoryData.map((item, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12 }}>
                  <div style={{ width: 10, height: 10, borderRadius: 3, background: COLORS[i] }} />
                  {item.name} ({item.value}٪)
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Recent Jobs Table */}
        <div className="table-card">
          <div className="table-header">
            <h3>أحدث الطلبات</h3>
            <button className="btn btn-outline">عرض الكل</button>
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
              </tr>
            </thead>
            <tbody>
              {recentJobs.map((job) => (
                <tr key={job.id}>
                  <td style={{ fontWeight: 600 }}>{job.id}</td>
                  <td>{job.customer}</td>
                  <td>{job.service}</td>
                  <td>{job.tech}</td>
                  <td><span className={`badge ${job.statusClass}`}>{job.status}</span></td>
                  <td style={{ fontWeight: 600 }}>{job.amount}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
