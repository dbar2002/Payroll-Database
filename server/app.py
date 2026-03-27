from flask import Flask, request, jsonify, g, send_from_directory
from flask_cors import CORS
import sqlite3
import os

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

app = Flask(__name__, static_folder=None)
CORS(app)


@app.route('/')
def index():
    return send_from_directory(os.path.join(BASE_DIR, 'dashboard'), 'index.html')


@app.route('/css/<path:filename>')
def serve_css(filename):
    return send_from_directory(os.path.join(BASE_DIR, 'dashboard', 'css'), filename)


@app.route('/js/<path:filename>')
def serve_js(filename):
    return send_from_directory(os.path.join(BASE_DIR, 'dashboard', 'js'), filename)


@app.route('/sql/<path:filename>')
def serve_sql(filename):
    return send_from_directory(os.path.join(BASE_DIR, 'sql'), filename)

DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'payroll.db')


def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(DB_PATH)
        g.db.row_factory = sqlite3.Row
        g.db.execute('PRAGMA foreign_keys = ON')
    return g.db


@app.teardown_appcontext
def close_db(exception):
    db = g.pop('db', None)
    if db is not None:
        db.close()


def rows_to_list(rows):
    return [dict(row) for row in rows]


def error(msg, code=400):
    return jsonify({'error': msg}), code


# ── employees ──

@app.route('/api/employees', methods=['GET'])
def get_employees():
    db = get_db()
    search = request.args.get('search', '')
    dept = request.args.get('department', '')
    status = request.args.get('status', '')

    sql = '''
        SELECT e.*, d.name AS department_name
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        WHERE 1=1
    '''
    params = []

    if search:
        sql += " AND (e.first_name || ' ' || e.last_name LIKE ? OR e.job_title LIKE ?)"
        params += [f'%{search}%', f'%{search}%']
    if dept:
        sql += ' AND d.name = ?'
        params.append(dept)
    if status:
        sql += ' AND e.employment_status = ?'
        params.append(status)

    sql += ' ORDER BY e.employee_id'
    return jsonify(rows_to_list(db.execute(sql, params).fetchall()))


@app.route('/api/employees/<int:id>', methods=['GET'])
def get_employee(id):
    db = get_db()
    row = db.execute('''
        SELECT e.*, d.name AS department_name
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        WHERE e.employee_id = ?
    ''', (id,)).fetchone()
    if not row:
        return error('Employee not found', 404)
    return jsonify(dict(row))


@app.route('/api/employees', methods=['POST'])
def create_employee():
    db = get_db()
    data = request.json
    required = ['first_name', 'last_name', 'email', 'date_of_birth', 'job_title', 'department_id', 'base_salary']
    for field in required:
        if field not in data:
            return error(f'Missing required field: {field}')
    try:
        cursor = db.execute('''
            INSERT INTO employees (first_name, last_name, email, phone, gender, address,
                date_of_birth, hire_date, job_title, department_id, employment_status,
                pay_frequency, base_salary)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['first_name'], data['last_name'], data['email'],
            data.get('phone'), data.get('gender'), data.get('address'),
            data['date_of_birth'], data.get('hire_date') or __import__('datetime').date.today().isoformat(),
            data['job_title'], data['department_id'],
            data.get('employment_status', 'active'),
            data.get('pay_frequency', 'monthly'),
            data['base_salary']
        ))
        db.commit()
        return jsonify({'employee_id': cursor.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return error(str(e))


@app.route('/api/employees/<int:id>', methods=['PUT'])
def update_employee(id):
    db = get_db()
    data = request.json
    fields = []
    values = []
    allowed = ['first_name', 'last_name', 'email', 'phone', 'gender', 'address',
               'date_of_birth', 'hire_date', 'termination_date', 'job_title',
               'department_id', 'employment_status', 'pay_frequency', 'base_salary']
    for key in allowed:
        if key in data:
            fields.append(f'{key} = ?')
            values.append(data[key])
    if not fields:
        return error('No valid fields to update')
    values.append(id)
    try:
        db.execute(f'UPDATE employees SET {", ".join(fields)} WHERE employee_id = ?', values)
        db.commit()
        return jsonify({'updated': id})
    except sqlite3.IntegrityError as e:
        return error(str(e))


@app.route('/api/employees/<int:id>', methods=['DELETE'])
def delete_employee(id):
    db = get_db()
    db.execute('DELETE FROM employees WHERE employee_id = ?', (id,))
    db.commit()
    return jsonify({'deleted': id})


# ── departments ──

@app.route('/api/departments', methods=['GET'])
def get_departments():
    db = get_db()
    rows = db.execute('''
        SELECT d.*,
            m.first_name || ' ' || m.last_name AS manager_name,
            COUNT(e.employee_id) AS headcount,
            COALESCE(SUM(e.base_salary), 0) AS total_salaries
        FROM departments d
        LEFT JOIN employees m ON d.manager_id = m.employee_id
        LEFT JOIN employees e ON e.department_id = d.department_id
            AND e.employment_status IN ('active', 'probation')
        GROUP BY d.department_id
    ''').fetchall()
    return jsonify(rows_to_list(rows))


@app.route('/api/departments', methods=['POST'])
def create_department():
    db = get_db()
    data = request.json
    if 'name' not in data:
        return error('Missing required field: name')
    try:
        cursor = db.execute('''
            INSERT INTO departments (name, location, budget)
            VALUES (?, ?, ?)
        ''', (data['name'], data.get('location', 'HQ'), data.get('budget', 0)))
        db.commit()
        return jsonify({'department_id': cursor.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return error(str(e))


# ── payroll ──

@app.route('/api/payroll', methods=['GET'])
def get_payroll():
    db = get_db()
    employee_id = request.args.get('employee_id')
    month = request.args.get('month')

    sql = '''
        SELECT p.*, e.first_name || ' ' || e.last_name AS employee_name, d.name AS department_name
        FROM payroll p
        JOIN employees e ON p.employee_id = e.employee_id
        JOIN departments d ON e.department_id = d.department_id
        WHERE 1=1
    '''
    params = []
    if employee_id:
        sql += ' AND p.employee_id = ?'
        params.append(employee_id)
    if month:
        sql += ' AND p.pay_period_start LIKE ?'
        params.append(f'{month}%')
    sql += ' ORDER BY p.pay_period_start DESC, p.gross_salary DESC'
    return jsonify(rows_to_list(db.execute(sql, params).fetchall()))


@app.route('/api/payroll', methods=['POST'])
def create_payroll():
    db = get_db()
    data = request.json
    required = ['employee_id', 'pay_period_start', 'pay_period_end', 'gross_salary']
    for field in required:
        if field not in data:
            return error(f'Missing required field: {field}')
    try:
        cursor = db.execute('''
            INSERT INTO payroll (employee_id, pay_period_start, pay_period_end,
                gross_salary, total_deductions, payment_date, payment_method, payment_status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['employee_id'], data['pay_period_start'], data['pay_period_end'],
            data['gross_salary'], data.get('total_deductions', 0),
            data.get('payment_date'), data.get('payment_method', 'direct_deposit'),
            data.get('payment_status', 'pending')
        ))
        db.commit()
        return jsonify({'payroll_id': cursor.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return error(str(e))


# ── deductions ──

@app.route('/api/payroll/<int:payroll_id>/deductions', methods=['GET'])
def get_deductions(payroll_id):
    db = get_db()
    rows = db.execute('SELECT * FROM deductions WHERE payroll_id = ?', (payroll_id,)).fetchall()
    return jsonify(rows_to_list(rows))


@app.route('/api/deductions', methods=['POST'])
def create_deduction():
    db = get_db()
    data = request.json
    required = ['payroll_id', 'deduction_type', 'amount']
    for field in required:
        if field not in data:
            return error(f'Missing required field: {field}')
    try:
        cursor = db.execute('''
            INSERT INTO deductions (payroll_id, deduction_type, amount, description)
            VALUES (?, ?, ?, ?)
        ''', (data['payroll_id'], data['deduction_type'], data['amount'], data.get('description')))
        db.commit()
        return jsonify({'deduction_id': cursor.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return error(str(e))


# ── performance reviews ──

@app.route('/api/reviews', methods=['GET'])
def get_reviews():
    db = get_db()
    employee_id = request.args.get('employee_id')
    sql = '''
        SELECT pr.*, e.first_name || ' ' || e.last_name AS employee_name,
            r.first_name || ' ' || r.last_name AS reviewer_name,
            d.name AS department_name
        FROM performance_reviews pr
        JOIN employees e ON pr.employee_id = e.employee_id
        JOIN employees r ON pr.reviewer_id = r.employee_id
        JOIN departments d ON e.department_id = d.department_id
    '''
    params = []
    if employee_id:
        sql += ' WHERE pr.employee_id = ?'
        params.append(employee_id)
    sql += ' ORDER BY pr.review_date DESC'
    return jsonify(rows_to_list(db.execute(sql, params).fetchall()))


@app.route('/api/reviews', methods=['POST'])
def create_review():
    db = get_db()
    data = request.json
    required = ['employee_id', 'reviewer_id', 'review_period', 'rating']
    for field in required:
        if field not in data:
            return error(f'Missing required field: {field}')
    try:
        cursor = db.execute('''
            INSERT INTO performance_reviews (employee_id, reviewer_id, review_date,
                review_period, rating, status, comments, goals)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['employee_id'], data['reviewer_id'],
            data.get('review_date', None), data['review_period'],
            data['rating'], data.get('status', 'draft'),
            data.get('comments'), data.get('goals')
        ))
        db.commit()
        return jsonify({'review_id': cursor.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return error(str(e))


# ── bonuses ──

@app.route('/api/bonuses', methods=['GET'])
def get_bonuses():
    db = get_db()
    sql = '''
        SELECT b.*, e.first_name || ' ' || e.last_name AS employee_name,
            a.first_name || ' ' || a.last_name AS approver_name
        FROM bonuses b
        JOIN employees e ON b.employee_id = e.employee_id
        LEFT JOIN employees a ON b.approved_by = a.employee_id
        ORDER BY b.date_awarded DESC
    '''
    return jsonify(rows_to_list(db.execute(sql).fetchall()))


@app.route('/api/bonuses', methods=['POST'])
def create_bonus():
    db = get_db()
    data = request.json
    required = ['employee_id', 'amount', 'bonus_type']
    for field in required:
        if field not in data:
            return error(f'Missing required field: {field}')
    try:
        cursor = db.execute('''
            INSERT INTO bonuses (employee_id, amount, bonus_type, date_awarded, reason, review_id, approved_by)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['employee_id'], data['amount'], data['bonus_type'],
            data.get('date_awarded', None), data.get('reason'),
            data.get('review_id'), data.get('approved_by')
        ))
        db.commit()
        return jsonify({'bonus_id': cursor.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return error(str(e))


# ── salary history ──

@app.route('/api/salary-history/<int:employee_id>', methods=['GET'])
def get_salary_history(employee_id):
    db = get_db()
    rows = db.execute('''
        SELECT sh.*, COALESCE(a.first_name || ' ' || a.last_name, NULL) AS approver_name
        FROM salary_history sh
        LEFT JOIN employees a ON sh.approved_by = a.employee_id
        WHERE sh.employee_id = ?
        ORDER BY sh.effective_date
    ''', (employee_id,)).fetchall()
    return jsonify(rows_to_list(rows))


# ── stats ──

@app.route('/api/stats', methods=['GET'])
def get_stats():
    db = get_db()
    stats = {}
    stats['employees'] = db.execute("SELECT COUNT(*) FROM employees WHERE employment_status IN ('active','probation')").fetchone()[0]
    stats['departments'] = db.execute("SELECT COUNT(*) FROM departments WHERE is_active = 1").fetchone()[0]
    stats['total_payroll'] = db.execute("SELECT COALESCE(SUM(base_salary), 0) FROM employees WHERE employment_status IN ('active','probation')").fetchone()[0]
    stats['avg_salary'] = db.execute("SELECT COALESCE(AVG(base_salary), 0) FROM employees WHERE employment_status IN ('active','probation')").fetchone()[0]
    stats['total_bonuses'] = db.execute("SELECT COALESCE(SUM(amount), 0) FROM bonuses").fetchone()[0]
    stats['avg_rating'] = db.execute("SELECT COALESCE(AVG(rating), 0) FROM performance_reviews WHERE review_period = 'annual'").fetchone()[0]
    return jsonify(stats)


# ── raw SQL (for the console) ──

@app.route('/api/query', methods=['POST'])
def run_query():
    data = request.json
    sql = data.get('sql', '').strip()
    if not sql:
        return error('No SQL provided')

    blocked = ['DROP', 'ALTER', 'PRAGMA']
    first_word = sql.split()[0].upper()
    if first_word in blocked:
        return error(f'{first_word} statements are not allowed')

    db = get_db()
    try:
        cursor = db.execute(sql)
        if first_word in ('INSERT', 'UPDATE', 'DELETE'):
            db.commit()
            return jsonify({'affected_rows': cursor.rowcount})
        columns = [desc[0] for desc in cursor.description] if cursor.description else []
        rows = [list(row) for row in cursor.fetchall()]
        return jsonify({'columns': columns, 'rows': rows})
    except Exception as e:
        return error(str(e))


if __name__ == '__main__':
    print(f'Database: {os.path.abspath(DB_PATH)}')
    print('Dashboard: http://127.0.0.1:8080')
    print()
    app.run(debug=True, port=8080)
