const COLORS = ['#5b8af5', '#3dd68c', '#f0b449', '#ef6461', '#a78bfa', '#f472b6', '#34d399', '#fb923c'];

function loadOverview() {
  const emp = query("SELECT COUNT(*) FROM employees WHERE employment_status IN ('active','probation')").rows[0][0];
  const totalSalary = query("SELECT SUM(base_salary) FROM employees WHERE employment_status IN ('active','probation')").rows[0][0];
  const avgSalary = query("SELECT AVG(base_salary) FROM employees WHERE employment_status IN ('active','probation')").rows[0][0];
  const totalBonuses = query("SELECT SUM(amount) FROM bonuses").rows[0][0];
  const depts = query("SELECT COUNT(*) FROM departments WHERE is_active = 1").rows[0][0];

  renderStats('overview-stats', [
    { label: 'Active employees', value: emp, sub: `${depts} departments` },
    { label: 'Total annual payroll', value: fmt(totalSalary), color: 'var(--accent)' },
    { label: 'Average salary', value: fmt(avgSalary) },
    { label: 'Total bonuses paid', value: fmt(totalBonuses), color: 'var(--green)' },
  ]);

  const salaryData = query(`
    SELECT d.name, ROUND(AVG(e.base_salary)) as avg
    FROM employees e JOIN departments d ON e.department_id = d.department_id
    WHERE e.employment_status IN ('active','probation')
    GROUP BY d.name ORDER BY avg DESC
  `);
  renderBarChart('chart-salary', salaryData.rows.map((r, i) => ({
    label: r[0], value: r[1], color: COLORS[i % COLORS.length]
  })));

  const budgetData = query(`
    SELECT d.name, ROUND(SUM(e.base_salary) * 100.0 / d.budget, 1) as util
    FROM departments d
    LEFT JOIN employees e ON e.department_id = d.department_id AND e.employment_status IN ('active','probation')
    GROUP BY d.department_id ORDER BY util DESC
  `);
  renderBarChart('chart-budget', budgetData.rows.map(r => ({
    label: r[0], value: r[1], display: r[1] + '%',
    color: r[1] > 80 ? 'var(--red)' : r[1] > 60 ? 'var(--amber)' : 'var(--green)'
  })));

  const bonusData = query(`
    SELECT e.first_name || ' ' || e.last_name, b.bonus_type, b.amount, b.date_awarded, b.reason
    FROM bonuses b JOIN employees e ON b.employee_id = e.employee_id
    ORDER BY b.date_awarded DESC LIMIT 10
  `);
  renderTable('table-bonuses', bonusData, {
    amount: v => `<span class="salary">${fmt2(v)}</span>`,
    bonus_type: v => `<span class="badge badge-active">${v}</span>`
  });
}

function loadEmployees(filter = '') {
  let sql = `
    SELECT e.employee_id, e.first_name || ' ' || e.last_name AS name, e.job_title,
           d.name AS department, e.employment_status AS status, e.base_salary AS salary,
           e.hire_date, e.pay_frequency
    FROM employees e JOIN departments d ON e.department_id = d.department_id
  `;
  if (filter) {
    const f = filter.replace(/'/g, "''");
    sql += ` WHERE name LIKE '%${f}%' OR e.job_title LIKE '%${f}%' OR d.name LIKE '%${f}%'`;
  }
  sql += ' ORDER BY e.base_salary DESC';

  renderTable('table-employees', query(sql), {
    status: v => badge(v),
    salary: v => `<span class="salary">${fmt(v)}</span>`,
  });
}

function loadPayroll() {
  const jan = query("SELECT SUM(gross_salary), SUM(total_deductions), SUM(net_salary) FROM payroll WHERE pay_period_start >= '2026-01-01' AND pay_period_start < '2026-02-01'");
  const feb = query("SELECT SUM(gross_salary), SUM(total_deductions), SUM(net_salary) FROM payroll WHERE pay_period_start >= '2026-02-01' AND pay_period_start < '2026-03-01'");

  renderStats('payroll-stats', [
    { label: 'Jan 2026 gross', value: fmt2(jan.rows[0][0]), color: 'var(--accent)' },
    { label: 'Jan 2026 net', value: fmt2(jan.rows[0][2]), color: 'var(--green)' },
    { label: 'Feb 2026 gross', value: fmt2(feb.rows[0][0]), color: 'var(--accent)' },
    { label: 'Total deductions', value: fmt2(jan.rows[0][1] + feb.rows[0][1]), color: 'var(--red)' },
  ]);

  const dedData = query(`
    SELECT deduction_type, SUM(amount) as total
    FROM deductions GROUP BY deduction_type ORDER BY total DESC LIMIT 8
  `);
  renderBarChart('chart-deductions', dedData.rows.map((r, i) => ({
    label: r[0].replace('_', ' '), value: r[1], color: COLORS[i % COLORS.length]
  })));

  const netData = query(`
    SELECT d.name, SUM(p.net_salary) as net
    FROM payroll p
    JOIN employees e ON p.employee_id = e.employee_id
    JOIN departments d ON e.department_id = d.department_id
    WHERE p.pay_period_start >= '2026-01-01' AND p.pay_period_start < '2026-02-01'
    GROUP BY d.name ORDER BY net DESC
  `);
  renderBarChart('chart-net', netData.rows.map((r, i) => ({
    label: r[0], value: r[1], color: COLORS[i % COLORS.length]
  })), 'var(--green)');

  const payData = query(`
    SELECT e.first_name || ' ' || e.last_name AS employee, d.name AS department,
           p.pay_period_start || ' — ' || p.pay_period_end AS period,
           p.gross_salary, p.total_deductions, p.net_salary, p.payment_status
    FROM payroll p
    JOIN employees e ON p.employee_id = e.employee_id
    JOIN departments d ON e.department_id = d.department_id
    ORDER BY p.pay_period_start DESC, p.gross_salary DESC LIMIT 25
  `);
  renderTable('table-payroll', payData, {
    gross_salary: v => `<span class="salary">${fmt2(v)}</span>`,
    total_deductions: v => `<span class="salary" style="color:var(--red)">${fmt2(v)}</span>`,
    net_salary: v => `<span class="salary" style="color:var(--green)">${fmt2(v)}</span>`,
    payment_status: v => badge(v === 'paid' ? 'active' : 'probation'),
  });
}

function loadReviews() {
  const avg = query("SELECT ROUND(AVG(rating),2), COUNT(*), SUM(CASE WHEN rating >= 4 THEN 1 ELSE 0 END) FROM performance_reviews WHERE review_period = 'annual'");
  const topCount = query("SELECT COUNT(*) FROM performance_reviews WHERE rating = 5 AND review_period = 'annual'").rows[0][0];

  renderStats('review-stats', [
    { label: 'Average rating', value: avg.rows[0][0], color: 'var(--amber)' },
    { label: 'Total reviews', value: avg.rows[0][1] },
    { label: 'High performers (4+)', value: avg.rows[0][2], color: 'var(--green)', sub: `${topCount} rated 5/5` },
  ]);

  const revData = query(`
    SELECT e.first_name || ' ' || e.last_name AS employee, e.job_title,
           d.name AS department, pr.review_period AS period, pr.rating,
           pr.status, pr.comments
    FROM performance_reviews pr
    JOIN employees e ON pr.employee_id = e.employee_id
    JOIN departments d ON e.department_id = d.department_id
    ORDER BY pr.rating DESC, pr.review_date DESC
  `);
  renderTable('table-reviews', revData, {
    rating: v => stars(v),
    status: v => badge(v === 'acknowledged' ? 'active' : 'probation'),
    comments: v => v && v.length > 60 ? v.substring(0, 60) + '...' : (v || '—'),
  });
}
