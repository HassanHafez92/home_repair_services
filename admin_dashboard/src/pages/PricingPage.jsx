import { useState } from 'react';

const categories = [
  {
    id: 'plumbing',
    nameAr: 'سباكة',
    icon: '🔧',
    inspectionFee: 75,
    minLabor: 100,
    maxLabor: 800,
    surgeMultiplier: 1.5,
    zones: [
      { name: 'القاهرة الكبرى', fee: 75 },
      { name: 'الإسكندرية', fee: 85 },
      { name: '٦ أكتوبر', fee: 90 },
    ]
  },
  {
    id: 'electrical',
    nameAr: 'كهرباء',
    icon: '⚡',
    inspectionFee: 75,
    minLabor: 100,
    maxLabor: 1000,
    surgeMultiplier: 1.5,
    zones: [
      { name: 'القاهرة الكبرى', fee: 75 },
      { name: 'الإسكندرية', fee: 85 },
    ]
  },
  {
    id: 'hvac',
    nameAr: 'تكييف',
    icon: '❄️',
    inspectionFee: 100,
    minLabor: 150,
    maxLabor: 1500,
    surgeMultiplier: 2.0,
    zones: [
      { name: 'القاهرة الكبرى', fee: 100 },
      { name: 'الإسكندرية', fee: 110 },
    ]
  },
  {
    id: 'carpentry',
    nameAr: 'نجارة',
    icon: '🪵',
    inspectionFee: 75,
    minLabor: 200,
    maxLabor: 2000,
    surgeMultiplier: 1.3,
    zones: [
      { name: 'القاهرة الكبرى', fee: 75 },
    ]
  },
];

export default function PricingPage() {
  const [selected, setSelected] = useState(null);

  return (
    <>
      <div className="topbar">
        <h1>إدارة التسعير</h1>
        <div className="topbar-actions">
          <button className="btn btn-primary">+ إضافة فئة</button>
        </div>
      </div>

      <div className="page-content">
        {/* Platform fees */}
        <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)', marginBottom: 28 }}>
          <div className="stat-card">
            <div className="stat-label">عمولة المنصة</div>
            <div className="stat-value" style={{ color: '#0D7377' }}>١٥٪</div>
            <div className="stat-label" style={{ fontSize: 11 }}>من كل طلب</div>
          </div>
          <div className="stat-card">
            <div className="stat-label">صندوق المخاطر</div>
            <div className="stat-value" style={{ color: '#E8A838' }}>٢٪</div>
            <div className="stat-label" style={{ fontSize: 11 }}>خصم تلقائي</div>
          </div>
          <div className="stat-card">
            <div className="stat-label">غرامة الإلغاء المتأخر</div>
            <div className="stat-value" style={{ color: '#E85D4A' }}>٥٠ ج.م</div>
            <div className="stat-label" style={{ fontSize: 11 }}>بعد قبول الفني</div>
          </div>
        </div>

        {/* Category Cards */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 16 }}>
          {categories.map(cat => (
            <div
              key={cat.id}
              className="chart-card"
              style={{ cursor: 'pointer', border: selected === cat.id ? '2px solid #0D7377' : undefined }}
              onClick={() => setSelected(selected === cat.id ? null : cat.id)}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
                <span style={{ fontSize: 28 }}>{cat.icon}</span>
                <div>
                  <h3 style={{ margin: 0 }}>{cat.nameAr}</h3>
                  <span style={{ fontSize: 12, color: '#6C757D' }}>ID: {cat.id}</span>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 12 }}>
                <div style={{ background: '#F0F2F5', padding: 12, borderRadius: 10 }}>
                  <div style={{ fontSize: 12, color: '#6C757D' }}>رسوم المعاينة</div>
                  <div style={{ fontSize: 18, fontWeight: 700 }}>{cat.inspectionFee} ج.م</div>
                </div>
                <div style={{ background: '#F0F2F5', padding: 12, borderRadius: 10 }}>
                  <div style={{ fontSize: 12, color: '#6C757D' }}>معامل الذروة</div>
                  <div style={{ fontSize: 18, fontWeight: 700 }}>×{cat.surgeMultiplier}</div>
                </div>
                <div style={{ background: '#F0F2F5', padding: 12, borderRadius: 10 }}>
                  <div style={{ fontSize: 12, color: '#6C757D' }}>حد أدنى أجرة</div>
                  <div style={{ fontSize: 18, fontWeight: 700 }}>{cat.minLabor} ج.م</div>
                </div>
                <div style={{ background: '#F0F2F5', padding: 12, borderRadius: 10 }}>
                  <div style={{ fontSize: 12, color: '#6C757D' }}>حد أقصى أجرة</div>
                  <div style={{ fontSize: 18, fontWeight: 700 }}>{cat.maxLabor} ج.م</div>
                </div>
              </div>

              {selected === cat.id && (
                <div style={{ marginTop: 16, paddingTop: 16, borderTop: '1px solid #E2E5EA' }}>
                  <h4 style={{ fontSize: 14, marginBottom: 8 }}>تسعير المناطق</h4>
                  {cat.zones.map((zone, i) => (
                    <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid #F0F2F5' }}>
                      <span>{zone.name}</span>
                      <span style={{ fontWeight: 700 }}>{zone.fee} ج.م</span>
                    </div>
                  ))}
                  <button className="btn btn-primary" style={{ marginTop: 12, width: '100%', justifyContent: 'center' }}>
                    تعديل الأسعار
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </>
  );
}
