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

// add employee button
document.getElementById('add-emp-btn').addEventListener('click', showAddEmployeeForm);

// sql console
document.getElementById('sql-run').addEventListener('click', async () => {
  const sql = document.getElementById('sql-input').value.trim();
  if (!sql) return;
  try {
    const result = await apiPost('/query', { sql });
    if (result.affected_rows !== undefined) {
      document.getElementById('sql-result').innerHTML =
        `<p style="color:var(--green);font-size:13px">${result.affected_rows} row(s) affected</p>`;
    } else {
      renderTable('sql-result', result);
    }
  } catch (err) {
    document.getElementById('sql-result').innerHTML =
      `<div class="sql-error">${err.message}</div>`;
  }
});

document.getElementById('sql-input').addEventListener('keydown', e => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
    document.getElementById('sql-run').click();
  }
});

// init
async function init() {
  try {
    const stats = await apiGet('/stats');
    document.getElementById('header-meta').textContent =
      `${stats.employees} employees · Flask + SQLite`;
    document.getElementById('loading').style.display = 'none';
    document.getElementById('app').classList.add('loaded');
    loadOverview();
  } catch (err) {
    document.getElementById('loading').innerHTML = `
      <p style="color:var(--red)">Cannot connect to server</p>
      <p style="color:var(--text-3);font-size:12px">Make sure the Flask server is running: python server/app.py</p>
    `;
  }
}

init();
