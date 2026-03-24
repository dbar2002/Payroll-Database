-- PayrollDB — Views & Triggers
-- sqlite3 payroll.db < sql/04_views_triggers.sql

PRAGMA foreign_keys = ON;


-- === views ===

-- employee summary with department and tenure
CREATE VIEW IF NOT EXISTS v_employee_summary AS
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.job_title,
    d.name AS department,
    e.employment_status,
    e.pay_frequency,
    e.base_salary,
    e.hire_date,
    ROUND((JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365.25, 1) AS years_tenure,
    d.name AS dept_name,
    m.first_name || ' ' || m.last_name AS dept_manager
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees m ON d.manager_id = m.employee_id;


-- payroll detail with employee info and deduction breakdown
CREATE VIEW IF NOT EXISTS v_payroll_detail AS
SELECT
    p.payroll_id,
    e.first_name || ' ' || e.last_name AS employee,
    d.name AS department,
    p.pay_period_start,
    p.pay_period_end,
    p.gross_salary,
    p.total_deductions,
    p.net_salary,
    p.payment_method,
    p.payment_status,
    p.payment_date
FROM payroll p
JOIN employees e ON p.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id;


-- department dashboard
CREATE VIEW IF NOT EXISTS v_department_dashboard AS
SELECT
    d.department_id,
    d.name,
    d.location,
    d.budget,
    d.is_active,
    m.first_name || ' ' || m.last_name AS manager,
    COUNT(e.employee_id) AS headcount,
    SUM(e.base_salary) AS total_salaries,
    ROUND(AVG(e.base_salary), 2) AS avg_salary,
    ROUND(SUM(e.base_salary) * 100.0 / d.budget, 1) AS budget_utilization
FROM departments d
LEFT JOIN employees m ON d.manager_id = m.employee_id
LEFT JOIN employees e ON e.department_id = d.department_id
    AND e.employment_status IN ('active', 'probation')
GROUP BY d.department_id;


-- review summary with reviewer name and bonus link
CREATE VIEW IF NOT EXISTS v_review_summary AS
SELECT
    pr.review_id,
    e.first_name || ' ' || e.last_name AS employee,
    e.job_title,
    d.name AS department,
    r.first_name || ' ' || r.last_name AS reviewer,
    pr.review_date,
    pr.review_period,
    pr.rating,
    pr.status,
    pr.comments,
    pr.goals,
    COALESCE(b.amount, 0) AS linked_bonus
FROM performance_reviews pr
JOIN employees e ON pr.employee_id = e.employee_id
JOIN employees r ON pr.reviewer_id = r.employee_id
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN bonuses b ON b.review_id = pr.review_id;


-- salary history with employee name and approver
CREATE VIEW IF NOT EXISTS v_salary_timeline AS
SELECT
    sh.salary_history_id,
    e.first_name || ' ' || e.last_name AS employee,
    e.job_title,
    d.name AS department,
    sh.old_salary,
    sh.new_salary,
    sh.change_percentage,
    sh.change_reason,
    sh.effective_date,
    COALESCE(a.first_name || ' ' || a.last_name, '—') AS approved_by
FROM salary_history sh
JOIN employees e ON sh.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees a ON sh.approved_by = a.employee_id;


-- compensation overview (salary + total bonuses per employee)
CREATE VIEW IF NOT EXISTS v_total_compensation AS
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.job_title,
    d.name AS department,
    e.base_salary,
    COALESCE(b.total_bonuses, 0) AS total_bonuses,
    e.base_salary + COALESCE(b.total_bonuses, 0) AS total_compensation
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN (
    SELECT employee_id, SUM(amount) AS total_bonuses
    FROM bonuses GROUP BY employee_id
) b ON e.employee_id = b.employee_id
WHERE e.employment_status IN ('active', 'probation');


-- === triggers ===

-- auto-log salary changes to salary_history when base_salary is updated
CREATE TRIGGER IF NOT EXISTS trg_salary_change
AFTER UPDATE OF base_salary ON employees
WHEN OLD.base_salary != NEW.base_salary
BEGIN
    INSERT INTO salary_history (employee_id, old_salary, new_salary, effective_date, change_reason)
    VALUES (NEW.employee_id, OLD.base_salary, NEW.base_salary, DATE('now'), 'adjustment');
END;


-- auto-set updated_at timestamp on employee changes
CREATE TRIGGER IF NOT EXISTS trg_employee_updated
AFTER UPDATE ON employees
BEGIN
    UPDATE employees SET updated_at = DATETIME('now')
    WHERE employee_id = NEW.employee_id;
END;


-- auto-set termination_date when status changes to terminated
CREATE TRIGGER IF NOT EXISTS trg_employee_terminated
AFTER UPDATE OF employment_status ON employees
WHEN NEW.employment_status = 'terminated' AND OLD.employment_status != 'terminated'
BEGIN
    UPDATE employees SET termination_date = DATE('now')
    WHERE employee_id = NEW.employee_id;
END;


-- prevent deleting a department that still has employees
CREATE TRIGGER IF NOT EXISTS trg_prevent_dept_delete
BEFORE DELETE ON departments
WHEN (SELECT COUNT(*) FROM employees WHERE department_id = OLD.department_id) > 0
BEGIN
    SELECT RAISE(ABORT, 'Cannot delete department with active employees');
END;


-- auto-update payroll total_deductions when deductions are inserted
CREATE TRIGGER IF NOT EXISTS trg_deduction_insert
AFTER INSERT ON deductions
BEGIN
    UPDATE payroll SET total_deductions = (
        SELECT COALESCE(SUM(amount), 0) FROM deductions WHERE payroll_id = NEW.payroll_id
    ) WHERE payroll_id = NEW.payroll_id;
END;


-- auto-update payroll total_deductions when deductions are deleted
CREATE TRIGGER IF NOT EXISTS trg_deduction_delete
AFTER DELETE ON deductions
BEGIN
    UPDATE payroll SET total_deductions = (
        SELECT COALESCE(SUM(amount), 0) FROM deductions WHERE payroll_id = OLD.payroll_id
    ) WHERE payroll_id = OLD.payroll_id;
END;


-- auto-update payroll total_deductions when deductions are updated
CREATE TRIGGER IF NOT EXISTS trg_deduction_update
AFTER UPDATE OF amount ON deductions
BEGIN
    UPDATE payroll SET total_deductions = (
        SELECT COALESCE(SUM(amount), 0) FROM deductions WHERE payroll_id = NEW.payroll_id
    ) WHERE payroll_id = NEW.payroll_id;
END;
