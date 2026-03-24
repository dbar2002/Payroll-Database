-- PayrollDB — Queries & Reports
-- sqlite3 payroll.db < sql/03_queries.sql

PRAGMA foreign_keys = ON;
.mode column
.headers on


-- === employee directory & demographics ===

-- full directory
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS full_name,
       e.job_title, d.name AS department, e.employment_status, e.base_salary, e.hire_date
FROM employees e JOIN departments d ON e.department_id = d.department_id
ORDER BY d.name, e.base_salary DESC;

-- headcount by department
SELECT d.name AS department, COUNT(*) AS headcount,
       SUM(CASE WHEN e.employment_status = 'active' THEN 1 ELSE 0 END) AS active,
       SUM(CASE WHEN e.employment_status = 'probation' THEN 1 ELSE 0 END) AS probation,
       SUM(CASE WHEN e.employment_status = 'on_leave' THEN 1 ELSE 0 END) AS on_leave
FROM employees e JOIN departments d ON e.department_id = d.department_id
GROUP BY d.name ORDER BY headcount DESC;

-- gender breakdown
SELECT gender, COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees), 1) AS percentage
FROM employees GROUP BY gender ORDER BY count DESC;

-- tenure
SELECT e.first_name || ' ' || e.last_name AS full_name, e.hire_date,
       ROUND((JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365.25, 1) AS years_tenure,
       e.job_title, d.name AS department
FROM employees e JOIN departments d ON e.department_id = d.department_id
WHERE e.employment_status != 'terminated'
ORDER BY years_tenure DESC;


-- === salary analysis ===

-- salary stats by department
SELECT d.name AS department, COUNT(*) AS employees,
       PRINTF('$%,.0f', MIN(e.base_salary)) AS min_salary,
       PRINTF('$%,.0f', AVG(e.base_salary)) AS avg_salary,
       PRINTF('$%,.0f', MAX(e.base_salary)) AS max_salary,
       PRINTF('$%,.0f', SUM(e.base_salary)) AS total_payroll
FROM employees e JOIN departments d ON e.department_id = d.department_id
WHERE e.employment_status IN ('active', 'probation')
GROUP BY d.name ORDER BY AVG(e.base_salary) DESC;

-- top 10 highest paid
SELECT e.first_name || ' ' || e.last_name AS full_name, e.job_title,
       d.name AS department, PRINTF('$%,.0f', e.base_salary) AS salary
FROM employees e JOIN departments d ON e.department_id = d.department_id
ORDER BY e.base_salary DESC LIMIT 10;

-- salary history (Marcus Chen)
SELECT sh.effective_date, PRINTF('$%,.0f', sh.old_salary) AS old_salary,
       PRINTF('$%,.0f', sh.new_salary) AS new_salary, sh.change_reason,
       sh.change_percentage || '%' AS change_pct,
       COALESCE(a.first_name || ' ' || a.last_name, '—') AS approved_by
FROM salary_history sh LEFT JOIN employees a ON sh.approved_by = a.employee_id
WHERE sh.employee_id = 1 ORDER BY sh.effective_date;

-- largest raises by percentage
SELECT e.first_name || ' ' || e.last_name AS full_name, sh.change_reason,
       PRINTF('$%,.0f', sh.old_salary) AS old_salary,
       PRINTF('$%,.0f', sh.new_salary) AS new_salary,
       sh.change_percentage || '%' AS change_pct, sh.effective_date
FROM salary_history sh JOIN employees e ON sh.employee_id = e.employee_id
WHERE sh.old_salary > 0 ORDER BY sh.change_percentage DESC LIMIT 10;

-- average raise by reason
SELECT change_reason, COUNT(*) AS count,
       ROUND(AVG(change_percentage), 2) || '%' AS avg_change,
       ROUND(MIN(change_percentage), 2) || '%' AS min_change,
       ROUND(MAX(change_percentage), 2) || '%' AS max_change
FROM salary_history WHERE old_salary > 0
GROUP BY change_reason ORDER BY AVG(change_percentage) DESC;


-- === payroll reports ===

-- monthly summary
SELECT SUBSTR(p.pay_period_start, 1, 7) AS month, COUNT(*) AS pay_records,
       PRINTF('$%,.2f', SUM(p.gross_salary)) AS total_gross,
       PRINTF('$%,.2f', SUM(p.total_deductions)) AS total_deductions,
       PRINTF('$%,.2f', SUM(p.net_salary)) AS total_net
FROM payroll p GROUP BY SUBSTR(p.pay_period_start, 1, 7) ORDER BY month;

-- payroll by department (Jan 2026)
SELECT d.name AS department, COUNT(*) AS employees_paid,
       PRINTF('$%,.2f', SUM(p.gross_salary)) AS gross_total,
       PRINTF('$%,.2f', SUM(p.total_deductions)) AS deductions,
       PRINTF('$%,.2f', SUM(p.net_salary)) AS net_total
FROM payroll p
JOIN employees e ON p.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE p.pay_period_start >= '2026-01-01' AND p.pay_period_start < '2026-02-01'
GROUP BY d.name ORDER BY SUM(p.gross_salary) DESC;

-- payment method distribution
SELECT payment_method, COUNT(*) AS records,
       PRINTF('$%,.2f', SUM(gross_salary)) AS total_amount,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payroll), 1) AS pct
FROM payroll GROUP BY payment_method ORDER BY records DESC;

-- payslip detail (Marcus Chen, Jan 2026)
SELECT e.first_name || ' ' || e.last_name AS employee,
       p.pay_period_start || ' to ' || p.pay_period_end AS period,
       PRINTF('$%,.2f', p.gross_salary) AS gross, d.deduction_type,
       PRINTF('$%,.2f', d.amount) AS amount
FROM payroll p
JOIN employees e ON p.employee_id = e.employee_id
JOIN deductions d ON p.payroll_id = d.payroll_id
WHERE e.employee_id = 1 AND p.pay_period_start = '2026-01-01'
ORDER BY d.amount DESC;


-- === deduction breakdowns ===

-- totals by type
SELECT deduction_type, COUNT(*) AS occurrences,
       PRINTF('$%,.2f', SUM(amount)) AS total,
       PRINTF('$%,.2f', AVG(amount)) AS avg_per_occurrence,
       ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM deductions), 1) AS pct
FROM deductions GROUP BY deduction_type ORDER BY SUM(amount) DESC;

-- deduction rate by employee (Jan 2026)
SELECT e.first_name || ' ' || e.last_name AS employee,
       PRINTF('$%,.2f', p.gross_salary) AS gross,
       PRINTF('$%,.2f', p.total_deductions) AS deductions,
       PRINTF('$%,.2f', p.net_salary) AS net,
       ROUND(p.total_deductions * 100.0 / p.gross_salary, 1) || '%' AS deduction_rate
FROM payroll p JOIN employees e ON p.employee_id = e.employee_id
WHERE p.pay_period_start >= '2026-01-01' AND p.pay_period_start < '2026-02-01'
ORDER BY p.total_deductions * 100.0 / p.gross_salary DESC;


-- === performance analytics ===

-- annual reviews ranked
SELECT e.first_name || ' ' || e.last_name AS employee, e.job_title,
       d.name AS department, pr.rating, pr.status,
       r.first_name || ' ' || r.last_name AS reviewer
FROM performance_reviews pr
JOIN employees e ON pr.employee_id = e.employee_id
JOIN employees r ON pr.reviewer_id = r.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE pr.review_period = 'annual'
ORDER BY pr.rating DESC, e.last_name;

-- avg rating by department
SELECT d.name AS department, COUNT(*) AS reviews,
       ROUND(AVG(pr.rating), 2) AS avg_rating,
       MIN(pr.rating) AS lowest, MAX(pr.rating) AS highest
FROM performance_reviews pr
JOIN employees e ON pr.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE pr.review_period = 'annual'
GROUP BY d.name ORDER BY avg_rating DESC;

-- rating distribution
SELECT rating, COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM performance_reviews), 1) AS percentage
FROM performance_reviews GROUP BY rating ORDER BY rating DESC;

-- top performers with salary
SELECT e.first_name || ' ' || e.last_name AS employee, e.job_title,
       d.name AS department, PRINTF('$%,.0f', e.base_salary) AS salary, pr.comments
FROM performance_reviews pr
JOIN employees e ON pr.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE pr.rating = 5 AND pr.review_period IN ('annual', 'Q4')
ORDER BY e.base_salary DESC;


-- === bonus reports ===

-- summary by type
SELECT bonus_type, COUNT(*) AS count, PRINTF('$%,.2f', SUM(amount)) AS total,
       PRINTF('$%,.2f', AVG(amount)) AS average, PRINTF('$%,.2f', MAX(amount)) AS largest
FROM bonuses GROUP BY bonus_type ORDER BY SUM(amount) DESC;

-- total bonuses by employee
SELECT e.first_name || ' ' || e.last_name AS employee, e.job_title,
       COUNT(b.bonus_id) AS bonus_count, PRINTF('$%,.2f', SUM(b.amount)) AS total_bonuses,
       PRINTF('$%,.0f', e.base_salary) AS base_salary,
       ROUND(SUM(b.amount) * 100.0 / e.base_salary, 1) || '%' AS bonus_pct
FROM bonuses b JOIN employees e ON b.employee_id = e.employee_id
GROUP BY e.employee_id ORDER BY SUM(b.amount) DESC;

-- performance bonuses with review link
SELECT e.first_name || ' ' || e.last_name AS employee,
       PRINTF('$%,.2f', b.amount) AS bonus, pr.rating, pr.review_period,
       a.first_name || ' ' || a.last_name AS approved_by
FROM bonuses b
JOIN employees e ON b.employee_id = e.employee_id
JOIN performance_reviews pr ON b.review_id = pr.review_id
LEFT JOIN employees a ON b.approved_by = a.employee_id
WHERE b.bonus_type = 'performance' ORDER BY b.amount DESC;


-- === department insights ===

-- overview with budget utilization
SELECT d.name AS department, m.first_name || ' ' || m.last_name AS manager,
       COUNT(e.employee_id) AS headcount,
       PRINTF('$%,.0f', SUM(e.base_salary)) AS total_salaries,
       PRINTF('$%,.0f', d.budget) AS budget,
       ROUND(SUM(e.base_salary) * 100.0 / d.budget, 1) || '%' AS utilization
FROM departments d
LEFT JOIN employees m ON d.manager_id = m.employee_id
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id ORDER BY SUM(e.base_salary) DESC;

-- total cost (salary + bonuses)
SELECT d.name AS department,
       PRINTF('$%,.0f', SUM(e.base_salary)) AS salaries,
       PRINTF('$%,.0f', COALESCE(bt.total, 0)) AS bonuses,
       PRINTF('$%,.0f', SUM(e.base_salary) + COALESCE(bt.total, 0)) AS total_cost
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN (
    SELECT e2.department_id, SUM(b.amount) AS total
    FROM bonuses b JOIN employees e2 ON b.employee_id = e2.employee_id
    GROUP BY e2.department_id
) bt ON d.department_id = bt.department_id
GROUP BY d.department_id
ORDER BY SUM(e.base_salary) + COALESCE(bt.total, 0) DESC;


-- === advanced (CTEs & window functions) ===

-- salary rank within department
SELECT d.name AS department, e.first_name || ' ' || e.last_name AS employee,
       PRINTF('$%,.0f', e.base_salary) AS salary,
       RANK() OVER (PARTITION BY e.department_id ORDER BY e.base_salary DESC) AS dept_rank
FROM employees e JOIN departments d ON e.department_id = d.department_id
WHERE e.employment_status IN ('active', 'probation')
ORDER BY d.name, dept_rank;

-- running payroll total by month
SELECT month, PRINTF('$%,.2f', monthly_gross) AS monthly_gross,
       PRINTF('$%,.2f', SUM(monthly_gross) OVER (ORDER BY month)) AS running_total
FROM (
    SELECT SUBSTR(pay_period_start, 1, 7) AS month, SUM(gross_salary) AS monthly_gross
    FROM payroll GROUP BY SUBSTR(pay_period_start, 1, 7)
) monthly;

-- salary growth timeline
WITH timeline AS (
    SELECT e.first_name || ' ' || e.last_name AS employee,
           sh.effective_date, sh.new_salary, sh.change_reason, sh.change_percentage,
           ROW_NUMBER() OVER (PARTITION BY sh.employee_id ORDER BY sh.effective_date) AS seq
    FROM salary_history sh JOIN employees e ON sh.employee_id = e.employee_id
)
SELECT employee, effective_date, PRINTF('$%,.0f', new_salary) AS salary, change_reason,
       CASE WHEN seq = 1 THEN 'initial' ELSE '+' || change_percentage || '%' END AS change
FROM timeline ORDER BY employee, effective_date;

-- high performers who got bonuses
WITH high_performers AS (
    SELECT DISTINCT employee_id FROM performance_reviews
    WHERE rating >= 4 AND review_period = 'annual'
),
bonus_recipients AS (
    SELECT employee_id, SUM(amount) AS total_bonus FROM bonuses
    WHERE bonus_type = 'performance' GROUP BY employee_id
)
SELECT e.first_name || ' ' || e.last_name AS employee, e.job_title,
       d.name AS department, pr.rating,
       PRINTF('$%,.2f', br.total_bonus) AS performance_bonus,
       PRINTF('$%,.0f', e.base_salary) AS salary
FROM high_performers hp
JOIN bonus_recipients br ON hp.employee_id = br.employee_id
JOIN employees e ON hp.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
JOIN performance_reviews pr ON e.employee_id = pr.employee_id AND pr.review_period = 'annual'
ORDER BY br.total_bonus DESC;

-- budget gap analysis
WITH annual_cost AS (
    SELECT department_id, SUM(base_salary) AS total_salary
    FROM employees WHERE employment_status IN ('active', 'probation')
    GROUP BY department_id
)
SELECT d.name AS department, PRINTF('$%,.0f', d.budget) AS budget,
       PRINTF('$%,.0f', ac.total_salary) AS salary_cost,
       PRINTF('$%,.0f', d.budget - ac.total_salary) AS remaining,
       CASE
           WHEN ac.total_salary > d.budget THEN 'OVER BUDGET'
           WHEN ac.total_salary > d.budget * 0.9 THEN 'NEAR LIMIT'
           ELSE 'ON TRACK'
       END AS status
FROM departments d JOIN annual_cost ac ON d.department_id = ac.department_id
ORDER BY (d.budget - ac.total_salary);