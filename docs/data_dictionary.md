# Data Dictionary

## departments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| department_id | INTEGER | PK, AUTO | Unique department identifier |
| name | TEXT | NOT NULL, UNIQUE | Department name |
| manager_id | INTEGER | FK → employees | Department head (nullable) |
| location | TEXT | NOT NULL, DEFAULT 'HQ' | Office location |
| budget | REAL | NOT NULL, CHECK ≥ 0 | Annual budget allocation |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation date |

## employees

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| employee_id | INTEGER | PK, AUTO | Unique employee identifier |
| first_name | TEXT | NOT NULL | Legal first name |
| last_name | TEXT | NOT NULL | Legal last name |
| email | TEXT | NOT NULL, UNIQUE | Work email address |
| phone | TEXT | nullable | Contact phone number |
| date_of_birth | TEXT | NOT NULL | Date of birth (YYYY-MM-DD) |
| hire_date | TEXT | NOT NULL, DEFAULT now | Employment start date |
| job_title | TEXT | NOT NULL | Current job title |
| department_id | INTEGER | NOT NULL, FK → departments | Assigned department |
| employment_status | TEXT | NOT NULL, CHECK enum | active / on_leave / terminated / probation |
| base_salary | REAL | NOT NULL, CHECK > 0 | Current annual base salary |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation timestamp |
| updated_at | TEXT | NOT NULL, DEFAULT now | Last update timestamp |

## salary_history

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| salary_history_id | INTEGER | PK, AUTO | Unique record identifier |
| employee_id | INTEGER | NOT NULL, FK → employees | Employee reference |
| old_salary | REAL | NOT NULL, CHECK ≥ 0 | Previous salary (0 for new hires) |
| new_salary | REAL | NOT NULL, CHECK > 0 | Updated salary amount |
| effective_date | TEXT | NOT NULL | Date change takes effect |
| change_reason | TEXT | NOT NULL, CHECK enum | hire / promotion / annual_raise / merit_raise / adjustment / demotion |
| change_percentage | REAL | GENERATED (stored) | Auto-calculated % change |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation timestamp |

## payroll

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| payroll_id | INTEGER | PK, AUTO | Unique payroll record |
| employee_id | INTEGER | NOT NULL, FK → employees | Employee reference |
| pay_period_start | TEXT | NOT NULL | Period start date |
| pay_period_end | TEXT | NOT NULL, CHECK > start | Period end date |
| gross_salary | REAL | NOT NULL, CHECK > 0 | Gross pay for the period |
| total_deductions | REAL | NOT NULL, DEFAULT 0 | Sum of all deductions |
| net_salary | REAL | GENERATED (stored) | gross - deductions (auto) |
| payment_date | TEXT | nullable | Actual payment date |
| payment_status | TEXT | NOT NULL, CHECK enum | pending / processed / paid / failed / cancelled |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation timestamp |

## deductions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| deduction_id | INTEGER | PK, AUTO | Unique deduction record |
| payroll_id | INTEGER | NOT NULL, FK → payroll | Parent payroll record |
| deduction_type | TEXT | NOT NULL, CHECK enum | federal_tax / state_tax / social_security / medicare / health_insurance / dental_insurance / vision_insurance / retirement_401k / hsa / other |
| amount | REAL | NOT NULL, CHECK > 0 | Deduction amount |
| description | TEXT | nullable | Optional notes |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation timestamp |

## performance_reviews

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| review_id | INTEGER | PK, AUTO | Unique review record |
| employee_id | INTEGER | NOT NULL, FK → employees | Employee being reviewed |
| reviewer_id | INTEGER | NOT NULL, FK → employees | Manager conducting review |
| review_date | TEXT | NOT NULL, DEFAULT now | Date of review |
| review_period | TEXT | NOT NULL, CHECK enum | Q1 / Q2 / Q3 / Q4 / annual / probation |
| rating | INTEGER | NOT NULL, CHECK 1-5 | Performance score |
| comments | TEXT | nullable | Reviewer feedback |
| goals | TEXT | nullable | Goals for next period |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation timestamp |

## bonuses

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| bonus_id | INTEGER | PK, AUTO | Unique bonus record |
| employee_id | INTEGER | NOT NULL, FK → employees | Recipient employee |
| amount | REAL | NOT NULL, CHECK > 0 | Bonus amount |
| bonus_type | TEXT | NOT NULL, CHECK enum | performance / signing / referral / holiday / spot / retention / other |
| date_awarded | TEXT | NOT NULL, DEFAULT now | Date bonus was awarded |
| reason | TEXT | nullable | Justification for bonus |
| review_id | INTEGER | FK → performance_reviews | Linked review (optional) |
| created_at | TEXT | NOT NULL, DEFAULT now | Record creation timestamp |
