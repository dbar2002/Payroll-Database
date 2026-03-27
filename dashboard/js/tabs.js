const COLORS = ['#5b8af5', '#3dd68c', '#f0b449', '#ef6461', '#a78bfa', '#f472b6', '#34d399', '#fb923c'];

// ── overview tab ──

async function loadOverview() {
  const stats = await apiGet('/stats');
  const depts = await apiGet('/departments');
  const bonuses = await apiGet('/bonuses');

  renderStats('overview-stats', [
    { label: 'Active employees', value: stats.employees, sub: `${stats.departments} departments` },
    { label: 'Total annual payroll', value: fmt(stats.total_payroll), color: 'var(--accent)' },
    { label: 'Average salary', value: fmt(stats.avg_salary) },
    { label: 'Total bonuses paid', value: fmt(stats.total_bonuses), color: 'var(--green)' },
  ]);

  const sorted = [...depts].sort((a, b) => (b.total_salaries / b.headcount || 0) - (a.total_salaries / a.headcount || 0));
  renderBarChart('chart-salary', sorted.map((d, i) => ({
    label: d.name, value: d.headcount > 0 ? Math.round(d.total_salaries / d.headcount) : 0,
    color: COLORS[i % COLORS.length]
  })));

  renderBarChart('chart-budget', depts.map(d => {
    const util = d.budget > 0 ? Math.round(d.total_salaries * 100 / d.budget * 10) / 10 : 0;
    return {
      label: d.name, value: util, display: util + '%',
      color: util > 80 ? 'var(--red)' : util > 60 ? 'var(--amber)' : 'var(--green)'
    };
  }).sort((a, b) => b.value - a.value));

  const bonusData = {
    columns: ['employee', 'type', 'amount', 'date', 'reason'],
    rows: bonuses.slice(0, 10).map(b => [b.employee_name, b.bonus_type, b.amount, b.date_awarded, b.reason])
  };
  renderTable('table-bonuses', bonusData, {
    amount: v => `<span class="salary">${fmt2(v)}</span>`,
    type: v => `<span class="badge badge-active">${v}</span>`
  });
}

// ── employees tab ──

async function loadEmployees(filter = '') {
  const params = filter ? `?search=${encodeURIComponent(filter)}` : '';
  const employees = await apiGet(`/employees${params}`);

  const data = {
    columns: ['id', 'name', 'title', 'department', 'status', 'salary', 'hired', 'actions'],
    rows: employees.map(e => [
      e.employee_id,
      e.first_name + ' ' + e.last_name,
      e.job_title,
      e.department_name,
      e.employment_status,
      e.base_salary,
      e.hire_date,
      e.employee_id
    ])
  };
  renderTable('table-employees', data, {
    status: v => badge(v),
    salary: v => `<span class="salary">${fmt(v)}</span>`,
    actions: v => `<button class="action-btn" onclick="editEmployee(${v})">Edit</button>
                   <button class="action-btn delete" onclick="deleteEmployee(${v})">Delete</button>`
  });
}

async function showAddEmployeeForm() {
  const depts = await apiGet('/departments');
  const deptOptions = depts.map(d => `<option value="${d.department_id}">${d.name}</option>`).join('');

  document.getElementById('modal').innerHTML = `
    <div class="modal-overlay" onclick="closeModal()">
      <div class="modal-card" onclick="event.stopPropagation()">
        <h3>Add employee</h3>
        <form id="add-emp-form">
          <div class="form-row">
            <div class="form-group"><label>First name</label><input name="first_name" required></div>
            <div class="form-group"><label>Last name</label><input name="last_name" required></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Email</label><input name="email" type="email" required></div>
            <div class="form-group"><label>Phone</label><input name="phone"></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Date of birth</label><input name="date_of_birth" type="date" required></div>
            <div class="form-group"><label>Hire date</label><input name="hire_date" type="date"></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Job title</label><input name="job_title" required></div>
            <div class="form-group"><label>Department</label><select name="department_id">${deptOptions}</select></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Salary</label><input name="base_salary" type="number" step="1000" required></div>
            <div class="form-group"><label>Pay frequency</label>
              <select name="pay_frequency">
                <option value="monthly">Monthly</option>
                <option value="semi_monthly">Semi-monthly</option>
                <option value="biweekly">Biweekly</option>
                <option value="weekly">Weekly</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Gender</label>
              <select name="gender">
                <option value="">—</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="non_binary">Non-binary</option>
                <option value="prefer_not_to_say">Prefer not to say</option>
              </select>
            </div>
            <div class="form-group"><label>Address</label><input name="address"></div>
          </div>
          <div class="form-actions">
            <button type="button" class="btn-secondary" onclick="closeModal()">Cancel</button>
            <button type="submit" class="sql-btn">Add employee</button>
          </div>
        </form>
      </div>
    </div>
  `;

  document.getElementById('add-emp-form').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const data = Object.fromEntries(fd);
    data.department_id = parseInt(data.department_id);
    data.base_salary = parseFloat(data.base_salary);
    if (!data.gender) delete data.gender;
    if (!data.phone) delete data.phone;
    if (!data.address) delete data.address;
    if (!data.hire_date) delete data.hire_date;
    try {
      await apiPost('/employees', data);
      closeModal();
      loadEmployees();
    } catch (err) {
      alert('Error: ' + err.message);
    }
  });
}

async function editEmployee(id) {
  const emp = await apiGet(`/employees/${id}`);
  const depts = await apiGet('/departments');
  const deptOptions = depts.map(d =>
    `<option value="${d.department_id}" ${d.department_id === emp.department_id ? 'selected' : ''}>${d.name}</option>`
  ).join('');

  document.getElementById('modal').innerHTML = `
    <div class="modal-overlay" onclick="closeModal()">
      <div class="modal-card" onclick="event.stopPropagation()">
        <h3>Edit employee</h3>
        <form id="edit-emp-form">
          <div class="form-row">
            <div class="form-group"><label>First name</label><input name="first_name" value="${emp.first_name}" required></div>
            <div class="form-group"><label>Last name</label><input name="last_name" value="${emp.last_name}" required></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Job title</label><input name="job_title" value="${emp.job_title}" required></div>
            <div class="form-group"><label>Department</label><select name="department_id">${deptOptions}</select></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Salary</label><input name="base_salary" type="number" step="1000" value="${emp.base_salary}" required></div>
            <div class="form-group"><label>Status</label>
              <select name="employment_status">
                ${['active','on_leave','terminated','probation'].map(s =>
                  `<option value="${s}" ${s === emp.employment_status ? 'selected' : ''}>${s.replace('_',' ')}</option>`
                ).join('')}
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group"><label>Email</label><input name="email" value="${emp.email}" required></div>
            <div class="form-group"><label>Phone</label><input name="phone" value="${emp.phone || ''}"></div>
          </div>
          <div class="form-actions">
            <button type="button" class="btn-secondary" onclick="closeModal()">Cancel</button>
            <button type="submit" class="sql-btn">Save changes</button>
          </div>
        </form>
      </div>
    </div>
  `;

  document.getElementById('edit-emp-form').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const data = Object.fromEntries(fd);
    data.department_id = parseInt(data.department_id);
    data.base_salary = parseFloat(data.base_salary);
    try {
      await apiPut(`/employees/${id}`, data);
      closeModal();
      loadEmployees();
    } catch (err) {
      alert('Error: ' + err.message);
    }
  });
}

async function deleteEmployee(id) {
  if (!confirm('Are you sure you want to delete this employee?')) return;
  try {
    await apiDelete(`/employees/${id}`);
    loadEmployees();
  } catch (err) {
    alert('Error: ' + err.message);
  }
}

function closeModal() {
  document.getElementById('modal').innerHTML = '';
}

// ── payroll tab ──

async function loadPayroll() {
  const payroll = await apiGet('/payroll');
  const jan = payroll.filter(p => p.pay_period_start.startsWith('2026-01'));
  const feb = payroll.filter(p => p.pay_period_start.startsWith('2026-02'));

  const sum = (arr, key) => arr.reduce((s, r) => s + (r[key] || 0), 0);

  renderStats('payroll-stats', [
    { label: 'Jan 2026 gross', value: fmt2(sum(jan, 'gross_salary')), color: 'var(--accent)' },
    { label: 'Jan 2026 net', value: fmt2(sum(jan, 'net_salary')), color: 'var(--green)' },
    { label: 'Feb 2026 gross', value: fmt2(sum(feb, 'gross_salary')), color: 'var(--accent)' },
    { label: 'Total deductions', value: fmt2(sum(jan, 'total_deductions') + sum(feb, 'total_deductions')), color: 'var(--red)' },
  ]);

  const data = {
    columns: ['employee', 'department', 'period', 'gross', 'deductions', 'net', 'status'],
    rows: payroll.slice(0, 25).map(p => [
      p.employee_name, p.department_name,
      p.pay_period_start + ' — ' + p.pay_period_end,
      p.gross_salary, p.total_deductions, p.net_salary, p.payment_status
    ])
  };
  renderTable('table-payroll', data, {
    gross: v => `<span class="salary">${fmt2(v)}</span>`,
    deductions: v => `<span class="salary" style="color:var(--red)">${fmt2(v)}</span>`,
    net: v => `<span class="salary" style="color:var(--green)">${fmt2(v)}</span>`,
    status: v => badge(v === 'paid' ? 'active' : 'probation'),
  });
}

// ── reviews tab ──

async function loadReviews() {
  const reviews = await apiGet('/reviews');
  const annual = reviews.filter(r => r.review_period === 'annual');
  const avgRating = annual.length ? (annual.reduce((s, r) => s + r.rating, 0) / annual.length).toFixed(2) : 0;
  const highPerf = annual.filter(r => r.rating >= 4).length;
  const top = annual.filter(r => r.rating === 5).length;

  renderStats('review-stats', [
    { label: 'Average rating', value: avgRating, color: 'var(--amber)' },
    { label: 'Total reviews', value: reviews.length },
    { label: 'High performers (4+)', value: highPerf, color: 'var(--green)', sub: `${top} rated 5/5` },
  ]);

  const data = {
    columns: ['employee', 'title', 'department', 'period', 'rating', 'status', 'comments'],
    rows: reviews.map(r => [
      r.employee_name, r.reviewer_name, r.department_name,
      r.review_period, r.rating, r.status, r.comments
    ])
  };
  renderTable('table-reviews', data, {
    rating: v => stars(v),
    status: v => badge(v === 'acknowledged' ? 'active' : 'probation'),
    comments: v => v && v.length > 60 ? v.substring(0, 60) + '...' : (v || '—'),
  });
}
