-- PayrollDB — Schema (DDL)
-- sqlite3 payroll.db < sql/01_schema.sql

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;


-- departments

CREATE TABLE IF NOT EXISTS departments (
    department_id       INTEGER     PRIMARY KEY AUTOINCREMENT,
    name                TEXT        NOT NULL UNIQUE,
    manager_id          INTEGER,
    location            TEXT        NOT NULL DEFAULT 'HQ',
    budget              REAL        NOT NULL DEFAULT 0.00
                                    CHECK (budget >= 0),
    is_active           INTEGER     NOT NULL DEFAULT 1
                                    CHECK (is_active IN (0, 1)),
    created_at          TEXT        NOT NULL DEFAULT (DATE('now')),

    FOREIGN KEY (manager_id) REFERENCES employees (employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- employees

CREATE TABLE IF NOT EXISTS employees (
    employee_id         INTEGER     PRIMARY KEY AUTOINCREMENT,
    first_name          TEXT        NOT NULL,
    last_name           TEXT        NOT NULL,
    email               TEXT        NOT NULL UNIQUE,
    phone               TEXT,
    gender              TEXT        CHECK (gender IN (
                                        'male', 'female', 'non_binary', 'prefer_not_to_say'
                                    )),
    address             TEXT,
    date_of_birth       TEXT        NOT NULL,
    hire_date           TEXT        NOT NULL DEFAULT (DATE('now')),
    termination_date    TEXT,
    job_title           TEXT        NOT NULL,
    department_id       INTEGER     NOT NULL,
    employment_status   TEXT        NOT NULL DEFAULT 'active'
                                    CHECK (employment_status IN (
                                        'active', 'on_leave', 'terminated', 'probation'
                                    )),
    pay_frequency       TEXT        NOT NULL DEFAULT 'monthly'
                                    CHECK (pay_frequency IN (
                                        'weekly', 'biweekly', 'semi_monthly', 'monthly'
                                    )),
    base_salary         REAL        NOT NULL CHECK (base_salary > 0),
    created_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),
    updated_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),

    FOREIGN KEY (department_id) REFERENCES departments (department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


-- salary_history

CREATE TABLE IF NOT EXISTS salary_history (
    salary_history_id   INTEGER     PRIMARY KEY AUTOINCREMENT,
    employee_id         INTEGER     NOT NULL,
    old_salary          REAL        NOT NULL CHECK (old_salary >= 0),
    new_salary          REAL        NOT NULL CHECK (new_salary > 0),
    effective_date      TEXT        NOT NULL,
    change_reason       TEXT        NOT NULL
                                    CHECK (change_reason IN (
                                        'hire', 'promotion', 'annual_raise',
                                        'merit_raise', 'adjustment', 'demotion'
                                    )),
    approved_by         INTEGER,
    change_percentage   REAL        GENERATED ALWAYS AS (
                                        CASE WHEN old_salary > 0
                                            THEN ROUND(((new_salary - old_salary) / old_salary) * 100, 2)
                                            ELSE 0.00
                                        END
                                    ) STORED,
    created_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),

    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees (employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- payroll

CREATE TABLE IF NOT EXISTS payroll (
    payroll_id          INTEGER     PRIMARY KEY AUTOINCREMENT,
    employee_id         INTEGER     NOT NULL,
    pay_period_start    TEXT        NOT NULL,
    pay_period_end      TEXT        NOT NULL,
    gross_salary        REAL        NOT NULL CHECK (gross_salary > 0),
    total_deductions    REAL        NOT NULL DEFAULT 0.00
                                    CHECK (total_deductions >= 0),
    net_salary          REAL        GENERATED ALWAYS AS (
                                        gross_salary - total_deductions
                                    ) STORED,
    payment_date        TEXT,
    payment_method      TEXT        NOT NULL DEFAULT 'direct_deposit'
                                    CHECK (payment_method IN (
                                        'direct_deposit', 'check', 'wire_transfer'
                                    )),
    payment_status      TEXT        NOT NULL DEFAULT 'pending'
                                    CHECK (payment_status IN (
                                        'pending', 'processed', 'paid', 'failed', 'cancelled'
                                    )),
    created_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),

    UNIQUE  (employee_id, pay_period_start, pay_period_end),
    CHECK   (pay_period_end > pay_period_start),

    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- deductions

CREATE TABLE IF NOT EXISTS deductions (
    deduction_id        INTEGER     PRIMARY KEY AUTOINCREMENT,
    payroll_id          INTEGER     NOT NULL,
    deduction_type      TEXT        NOT NULL
                                    CHECK (deduction_type IN (
                                        'federal_tax', 'state_tax', 'social_security', 'medicare',
                                        'health_insurance', 'dental_insurance', 'vision_insurance',
                                        'retirement_401k', 'hsa', 'other'
                                    )),
    amount              REAL        NOT NULL CHECK (amount > 0),
    description         TEXT,
    created_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),

    FOREIGN KEY (payroll_id) REFERENCES payroll (payroll_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- performance_reviews

CREATE TABLE IF NOT EXISTS performance_reviews (
    review_id           INTEGER     PRIMARY KEY AUTOINCREMENT,
    employee_id         INTEGER     NOT NULL,
    reviewer_id         INTEGER     NOT NULL,
    review_date         TEXT        NOT NULL DEFAULT (DATE('now')),
    review_period       TEXT        NOT NULL
                                    CHECK (review_period IN (
                                        'Q1', 'Q2', 'Q3', 'Q4', 'annual', 'probation'
                                    )),
    rating              INTEGER     NOT NULL CHECK (rating BETWEEN 1 AND 5),
    status              TEXT        NOT NULL DEFAULT 'draft'
                                    CHECK (status IN (
                                        'draft', 'submitted', 'acknowledged'
                                    )),
    comments            TEXT,
    goals               TEXT,
    created_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),

    UNIQUE (employee_id, review_period, review_date),

    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES employees (employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- bonuses

CREATE TABLE IF NOT EXISTS bonuses (
    bonus_id            INTEGER     PRIMARY KEY AUTOINCREMENT,
    employee_id         INTEGER     NOT NULL,
    amount              REAL        NOT NULL CHECK (amount > 0),
    bonus_type          TEXT        NOT NULL
                                    CHECK (bonus_type IN (
                                        'performance', 'signing', 'referral',
                                        'holiday', 'spot', 'retention', 'other'
                                    )),
    date_awarded        TEXT        NOT NULL DEFAULT (DATE('now')),
    reason              TEXT,
    review_id           INTEGER,
    approved_by         INTEGER,
    created_at          TEXT        NOT NULL DEFAULT (DATETIME('now')),

    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (review_id)  REFERENCES performance_reviews (review_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees (employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- indexes

CREATE INDEX idx_emp_department          ON employees            (department_id);
CREATE INDEX idx_emp_status              ON employees            (employment_status);
CREATE INDEX idx_emp_hire_date           ON employees            (hire_date);
CREATE INDEX idx_emp_name                ON employees            (last_name, first_name);

CREATE INDEX idx_sal_employee            ON salary_history       (employee_id);
CREATE INDEX idx_sal_effective_date      ON salary_history       (effective_date);
CREATE INDEX idx_sal_approver            ON salary_history       (approved_by);

CREATE INDEX idx_pay_employee            ON payroll              (employee_id);
CREATE INDEX idx_pay_period              ON payroll              (pay_period_start, pay_period_end);
CREATE INDEX idx_pay_status              ON payroll              (payment_status);
CREATE INDEX idx_pay_method              ON payroll              (payment_method);

CREATE INDEX idx_ded_payroll             ON deductions           (payroll_id);
CREATE INDEX idx_ded_type                ON deductions           (deduction_type);

CREATE INDEX idx_rev_employee            ON performance_reviews  (employee_id);
CREATE INDEX idx_rev_reviewer            ON performance_reviews  (reviewer_id);
CREATE INDEX idx_rev_date                ON performance_reviews  (review_date);
CREATE INDEX idx_rev_status              ON performance_reviews  (status);

CREATE INDEX idx_bon_employee            ON bonuses              (employee_id);
CREATE INDEX idx_bon_type                ON bonuses              (bonus_type);
CREATE INDEX idx_bon_date                ON bonuses              (date_awarded);
CREATE INDEX idx_bon_approver            ON bonuses              (approved_by);