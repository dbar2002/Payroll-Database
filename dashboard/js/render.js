function fmt(n) {
  return '$' + Number(n).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

function fmt2(n) {
  return '$' + Number(n).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function badge(status) {
  return `<span class="badge badge-${status}">${status.replace('_', ' ')}</span>`;
}

function stars(rating) {
  let h = '';
  for (let i = 1; i <= 5; i++) {
    h += `<svg class="star ${i <= rating ? 'star-filled' : 'star-empty'}" viewBox="0 0 20 20" fill="currentColor">
      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
    </svg>`;
  }
  return `<div class="rating">${h}</div>`;
}

function renderTable(containerId, data, formatters = {}) {
  if (data.error) {
    document.getElementById(containerId).innerHTML = `<div class="sql-error">${data.error}</div>`;
    return;
  }
  let html = '<table><thead><tr>';
  data.columns.forEach(c => html += `<th>${c}</th>`);
  html += '</tr></thead><tbody>';
  data.rows.forEach(row => {
    html += '<tr>';
    row.forEach((val, i) => {
      const col = data.columns[i];
      const formatted = formatters[col] ? formatters[col](val, row) : (val ?? '—');
      html += `<td>${formatted}</td>`;
    });
    html += '</tr>';
  });
  html += '</tbody></table>';
  document.getElementById(containerId).innerHTML = html;
}

function renderStats(containerId, stats) {
  let html = '';
  stats.forEach(s => {
    html += `<div class="stat-card">
      <div class="label">${s.label}</div>
      <div class="value" style="color:${s.color || 'var(--text)'}">${s.value}</div>
      ${s.sub ? `<div class="sub">${s.sub}</div>` : ''}
    </div>`;
  });
  document.getElementById(containerId).innerHTML = html;
}

function renderBarChart(containerId, data, defaultColor = 'var(--accent)') {
  const max = Math.max(...data.map(d => d.value));
  let html = '';
  data.forEach(d => {
    const pct = max > 0 ? (d.value / max * 100) : 0;
    html += `<div class="bar-row">
      <div class="bar-label">${d.label}</div>
      <div class="bar-track">
        <div class="bar-fill" style="width:${pct}%;background:${d.color || defaultColor}">${pct > 20 ? d.display || '' : ''}</div>
      </div>
      <div class="bar-value">${d.display || fmt(d.value)}</div>
    </div>`;
  });
  document.getElementById(containerId).innerHTML = html;
}
