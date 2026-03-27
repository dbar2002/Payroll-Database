# Payroll Database

A full-stack payroll and salary management system built with **SQLite**, **Flask**, and vanilla **JavaScript**.

## What it does

PayrollDB manages employee compensation data across seven interconnected tables — departments, employees, salary history, payroll records, deductions, performance reviews, and bonuses. Includes a REST API for CRUD operations and an interactive dashboard for browsing and editing data.

## Schema

**7 tables &middot; 67 columns &middot; 21 indexes**

```
departments ──< employees ──< salary_history
                    │
                    ├──< payroll ──< deductions
                    │
                    ├──< performance_reviews
                    │
                    └──< bonuses
```

| Table | Columns | Purpose |
|-------|---------|---------|
| `departments` | 7 | Organizational units with budget tracking |
| `employees` | 17 | Employee profiles, roles, and compensation |
| `salary_history` | 8 | Audit trail with auto-calculated % change |
| `payroll` | 10 | Pay period records with computed net salary |
| `deductions` | 6 | Itemized payroll deductions |
| `performance_reviews` | 10 | Periodic evaluations (1–5 scale) |
| `bonuses` | 9 | Bonus payments with approval tracking |

Key features: generated stored columns, CHECK constraints on all enums, 11 foreign keys with cascading rules, and soft-delete support.

See [`docs/PayrollDB_Schema_Reference.docx`](docs/PayrollDB_Schema_Reference.docx) for the full data dictionary.

## API

Flask REST API with 14 endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/stats` | Company-wide stats |
| GET | `/api/employees` | List employees (supports `?search=`, `?department=`, `?status=`) |
| GET | `/api/employees/:id` | Single employee detail |
| POST | `/api/employees` | Add new employee |
| PUT | `/api/employees/:id` | Update employee fields |
| DELETE | `/api/employees/:id` | Remove employee |
| GET | `/api/departments` | All departments with headcount and salary totals |
| POST | `/api/departments` | Create department |
| GET | `/api/payroll` | Payroll records (supports `?employee_id=`, `?month=`) |
| POST | `/api/payroll` | Create payroll entry |
| GET | `/api/reviews` | Performance reviews (supports `?employee_id=`) |
| POST | `/api/reviews` | Submit a review |
| GET | `/api/bonuses` | All bonuses |
| POST | `/api/bonuses` | Award a bonus |

Dangerous SQL statements (`DROP`, `ALTER`) are blocked in the SQL console endpoint.

## Dashboard

Interactive web dashboard with five tabs:

- **Overview** — stat cards, salary-by-department chart, budget utilization, recent bonuses
- **Employees** — searchable directory with add, edit, and delete
- **Payroll** — monthly gross/net stats and payroll records
- **Reviews** — rating averages and full review table with star ratings
- **SQL Console** — run queries against the live database (Cmd+Enter to execute)

## Getting started

```bash
git clone https://github.com/yourusername/PayrollDB.git
cd PayrollDB

# set up the database
sqlite3 payroll.db < sql/01_schema.sql
sqlite3 payroll.db < sql/02_seed_data.sql
sqlite3 payroll.db < sql/04_views_triggers.sql

# install and run the server
pip install -r server/requirements.txt
python server/app.py
```

Then open `http://localhost:5000/dashboard/`

## Project structure

```
PayrollDB/
├── server/
│   ├── app.py                 # Flask REST API
│   └── requirements.txt
├── dashboard/
│   ├── index.html
│   ├── css/styles.css
│   └── js/
│       ├── api.js             # HTTP client
│       ├── render.js          # Tables, charts, badges
│       ├── tabs.js            # Tab panel data loaders
│       └── app.js             # Init and event listeners
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_queries.sql
│   └── 04_views_triggers.sql
├── docs/
│   ├── PayrollDB_Schema_Reference.docx
│   ├── er_diagram.md
│   └── data_dictionary.md
├── .gitignore
├── LICENSE
└── README.md
```

## Tech stack

- **Database:** SQLite 3.39+
- **Backend:** Python, Flask, Flask-CORS
- **Frontend:** HTML, CSS, JavaScript
- **SQL features:** Generated columns, CTEs, window functions, triggers, views

## License

MIT — see [LICENSE](LICENSE) for details.
