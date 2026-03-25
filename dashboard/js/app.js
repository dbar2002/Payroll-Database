// tab switching
document.getElementById('tabs').addEventListener('click', e => {
  if (!e.target.classList.contains('tab')) return;
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
  e.target.classList.add('active');
  document.getElementById('panel-' + e.target.dataset.tab).classList.add('active');

  const tab = e.target.dataset.tab;
  if (tab === 'overview') loadOverview();
  if (tab === 'employees') loadEmployees();
  if (tab === 'payroll') loadPayroll();
  if (tab === 'reviews') loadReviews();
});

// employee search
let searchTimeout;
document.getElementById('emp-search').addEventListener('input', e => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => loadEmployees(e.target.value), 200);
});

// sql console
document.getElementById('sql-run').addEventListener('click', () => {
  const sql = document.getElementById('sql-input').value.trim();
  if (!sql) return;
  const result = query(sql);
  if (result.error) {
    document.getElementById('sql-result').innerHTML = `<div class="sql-error">${result.error}</div>`;
  } else {
    renderTable('sql-result', result);
  }
});

document.getElementById('sql-input').addEventListener('keydown', e => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
    document.getElementById('sql-run').click();
  }
});

// init
initDB()
  .then(() => {
    const empCount = query("SELECT COUNT(*) FROM employees").rows[0][0];
    document.getElementById('header-meta').textContent = `${empCount} employees · SQLite 3`;
    document.getElementById('loading').style.display = 'none';
    document.getElementById('app').classList.add('loaded');
    loadOverview();
  })
  .catch(err => {
    document.getElementById('loading').innerHTML = `
      <p style="color:var(--red)">Failed to load database</p>
      <p style="color:var(--text-3);font-size:12px">${err.message}</p>
    `;
  });
