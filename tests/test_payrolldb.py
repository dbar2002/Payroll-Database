import pytest
import sqlite3
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'server'))

SQL_DIR = os.path.join(os.path.dirname(__file__), '..', 'sql')


# ── fixtures ──

@pytest.fixture
def db():
    conn = sqlite3.connect(':memory:')
    conn.row_factory = sqlite3.Row
    conn.execute('PRAGMA foreign_keys = ON')
    for f in ['01_schema.sql', '02_seed_data.sql', '04_views_triggers.sql']:
        with open(os.path.join(SQL_DIR, f)) as fh:
            conn.executescript(fh.read())
    yield conn
    conn.close()


@pytest.fixture
def client(db):
    from app import app
    app.config['TESTING'] = True
    # patch get_db to use our in-memory db
    import app as app_module
    original_get_db = app_module.get_db

    def mock_get_db():
        from flask import g
        g.db = db
        return db

    app_module.get_db = mock_get_db
    with app.test_client() as c:
        with app.app_context():
            yield c
    app_module.get_db = original_get_db


# ── schema tests ──

class TestSchema:
    def test_all_tables_exist(self, db):
        tables = [r[0] for r in db.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
        ).fetchall()]
        assert tables == ['bonuses', 'deductions', 'departments', 'employees',
                          'payroll', 'performance_reviews', 'salary_history']

    def test_table_column_counts(self, db):
        expected = {'departments': 7, 'employees': 17, 'salary_history': 8,
                    'payroll': 10, 'deductions': 6, 'performance_reviews': 10, 'bonuses': 9}
        for table, count in expected.items():
            cols = db.execute(f'PRAGMA table_info({table})').fetchall()
            assert len(cols) == count, f'{table} has {len(cols)} columns, expected {count}'

    def test_index_count(self, db):
        count = db.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'").fetchone()[0]
        assert count == 21

    def test_foreign_keys_enabled(self, db):
        result = db.execute('PRAGMA foreign_keys').fetchone()[0]
        assert result == 1


# ── seed data tests ──

class TestSeedData:
    def test_department_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM departments').fetchone()[0]
        assert count == 5

    def test_employee_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM employees').fetchone()[0]
        assert count == 25

    def test_salary_history_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM salary_history').fetchone()[0]
        assert count == 30

    def test_payroll_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM payroll').fetchone()[0]
        assert count == 50

    def test_deduction_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM deductions').fetchone()[0]
        assert count >= 140

    def test_review_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM performance_reviews').fetchone()[0]
        assert count == 20

    def test_bonus_count(self, db):
        count = db.execute('SELECT COUNT(*) FROM bonuses').fetchone()[0]
        assert count == 15

    def test_all_departments_have_managers(self, db):
        rows = db.execute('SELECT name, manager_id FROM departments WHERE manager_id IS NULL').fetchall()
        assert len(rows) == 0, f'Departments without managers: {[r[0] for r in rows]}'

    def test_emails_are_unique(self, db):
        total = db.execute('SELECT COUNT(*) FROM employees').fetchone()[0]
        unique = db.execute('SELECT COUNT(DISTINCT email) FROM employees').fetchone()[0]
        assert total == unique


# ── constraint tests ──

class TestConstraints:
    def test_reject_negative_budget(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("INSERT INTO departments (name, budget) VALUES ('Bad', -100)")

    def test_reject_invalid_status(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO employees (first_name, last_name, email, date_of_birth,
                job_title, department_id, employment_status, base_salary)
                VALUES ('A', 'B', 'x@x.com', '1990-01-01', 'Dev', 1, 'fired', 50000)""")

    def test_reject_zero_salary(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO employees (first_name, last_name, email, date_of_birth,
                job_title, department_id, base_salary)
                VALUES ('A', 'B', 'y@y.com', '1990-01-01', 'Dev', 1, 0)""")

    def test_reject_invalid_pay_frequency(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO employees (first_name, last_name, email, date_of_birth,
                job_title, department_id, pay_frequency, base_salary)
                VALUES ('A', 'B', 'z@z.com', '1990-01-01', 'Dev', 1, 'daily', 50000)""")

    def test_reject_duplicate_email(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO employees (first_name, last_name, email, date_of_birth,
                job_title, department_id, base_salary)
                VALUES ('A', 'B', 'marcus.chen@company.com', '1990-01-01', 'Dev', 1, 50000)""")

    def test_reject_invalid_rating(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO performance_reviews
                (employee_id, reviewer_id, review_period, rating)
                VALUES (1, 1, 'Q1', 6)""")

    def test_reject_invalid_bonus_type(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("INSERT INTO bonuses (employee_id, amount, bonus_type) VALUES (1, 5000, 'lottery')")

    def test_reject_payroll_end_before_start(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO payroll (employee_id, pay_period_start, pay_period_end, gross_salary)
                VALUES (1, '2026-03-31', '2026-03-01', 5000)""")

    def test_reject_invalid_fk(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute("""INSERT INTO employees (first_name, last_name, email, date_of_birth,
                job_title, department_id, base_salary)
                VALUES ('A', 'B', 'fk@test.com', '1990-01-01', 'Dev', 999, 50000)""")

    def test_reject_drop_department_with_employees(self, db):
        with pytest.raises(sqlite3.IntegrityError):
            db.execute('DELETE FROM departments WHERE department_id = 1')


# ── generated column tests ──

class TestGeneratedColumns:
    def test_salary_change_percentage(self, db):
        row = db.execute("""SELECT change_percentage FROM salary_history
            WHERE employee_id = 1 AND change_reason = 'promotion' AND effective_date = '2023-01-01'
        """).fetchone()
        assert row[0] == 12.12

    def test_salary_change_percentage_hire(self, db):
        row = db.execute("""SELECT change_percentage FROM salary_history
            WHERE employee_id = 1 AND change_reason = 'hire'
        """).fetchone()
        assert row[0] == 0.0

    def test_net_salary_computed(self, db):
        row = db.execute('SELECT gross_salary, total_deductions, net_salary FROM payroll WHERE payroll_id = 1').fetchone()
        assert row[2] == row[0] - row[1]


# ── trigger tests ──

class TestTriggers:
    def test_salary_change_auto_logs(self, db):
        before = db.execute('SELECT COUNT(*) FROM salary_history').fetchone()[0]
        db.execute('UPDATE employees SET base_salary = 200000 WHERE employee_id = 1')
        after = db.execute('SELECT COUNT(*) FROM salary_history').fetchone()[0]
        assert after == before + 1

    def test_salary_log_has_correct_values(self, db):
        db.execute('UPDATE employees SET base_salary = 200000 WHERE employee_id = 1')
        row = db.execute("""SELECT old_salary, new_salary, change_reason
            FROM salary_history ORDER BY salary_history_id DESC LIMIT 1""").fetchone()
        assert row[0] == 185000.0
        assert row[1] == 200000.0
        assert row[2] == 'adjustment'

    def test_updated_at_auto_sets(self, db):
        db.execute("UPDATE employees SET job_title = 'CTO' WHERE employee_id = 1")
        row = db.execute('SELECT updated_at FROM employees WHERE employee_id = 1').fetchone()
        assert row[0] is not None

    def test_termination_date_auto_sets(self, db):
        db.execute("UPDATE employees SET employment_status = 'terminated' WHERE employee_id = 8")
        row = db.execute('SELECT termination_date FROM employees WHERE employee_id = 8').fetchone()
        assert row[0] is not None

    def test_deduction_insert_syncs_total(self, db):
        old = db.execute('SELECT total_deductions FROM payroll WHERE payroll_id = 1').fetchone()[0]
        db.execute("INSERT INTO deductions (payroll_id, deduction_type, amount) VALUES (1, 'other', 100)")
        new = db.execute('SELECT total_deductions FROM payroll WHERE payroll_id = 1').fetchone()[0]
        assert new == old + 100

    def test_deduction_delete_syncs_total(self, db):
        db.execute("INSERT INTO deductions (payroll_id, deduction_type, amount) VALUES (1, 'other', 100)")
        db.execute("DELETE FROM deductions WHERE payroll_id = 1 AND deduction_type = 'other'")
        row = db.execute('SELECT total_deductions FROM payroll WHERE payroll_id = 1').fetchone()
        assert row[0] == 4932.0


# ── view tests ──

class TestViews:
    def test_v_employee_summary(self, db):
        rows = db.execute('SELECT COUNT(*) FROM v_employee_summary').fetchone()[0]
        assert rows == 25

    def test_v_payroll_detail(self, db):
        rows = db.execute('SELECT COUNT(*) FROM v_payroll_detail').fetchone()[0]
        assert rows == 50

    def test_v_department_dashboard(self, db):
        rows = db.execute('SELECT COUNT(*) FROM v_department_dashboard').fetchone()[0]
        assert rows == 5

    def test_v_review_summary(self, db):
        rows = db.execute('SELECT COUNT(*) FROM v_review_summary').fetchone()[0]
        assert rows >= 20

    def test_v_salary_timeline(self, db):
        rows = db.execute('SELECT COUNT(*) FROM v_salary_timeline').fetchone()[0]
        assert rows == 30

    def test_v_total_compensation(self, db):
        rows = db.execute('SELECT COUNT(*) FROM v_total_compensation').fetchone()[0]
        assert rows >= 20


# ── API tests ──

class TestAPI:
    def test_get_stats(self, client):
        r = client.get('/api/stats')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert data['employees'] >= 24
        assert data['departments'] == 5

    def test_get_employees(self, client):
        r = client.get('/api/employees')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert len(data) >= 24

    def test_get_employee_by_id(self, client):
        r = client.get('/api/employees/1')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert data['first_name'] == 'Marcus'

    def test_employee_not_found(self, client):
        r = client.get('/api/employees/999')
        assert r.status_code == 404

    def test_search_employees(self, client):
        r = client.get('/api/employees?search=Marcus')
        data = json.loads(r.data)
        assert len(data) >= 1
        assert 'Marcus' in data[0]['first_name']

    def test_get_departments(self, client):
        r = client.get('/api/departments')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert len(data) == 5

    def test_get_payroll(self, client):
        r = client.get('/api/payroll')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert len(data) == 50

    def test_get_reviews(self, client):
        r = client.get('/api/reviews')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert len(data) == 20

    def test_get_bonuses(self, client):
        r = client.get('/api/bonuses')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert len(data) == 15

    def test_get_salary_history(self, client):
        r = client.get('/api/salary-history/1')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert len(data) == 3

    def test_sql_console(self, client):
        r = client.post('/api/query', data=json.dumps({'sql': 'SELECT COUNT(*) as c FROM employees'}),
                        content_type='application/json')
        assert r.status_code == 200
        data = json.loads(r.data)
        assert data['rows'][0][0] >= 24

    def test_sql_console_blocks_drop(self, client):
        r = client.post('/api/query', data=json.dumps({'sql': 'DROP TABLE employees'}),
                        content_type='application/json')
        assert r.status_code == 400
