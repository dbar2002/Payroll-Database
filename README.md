# Payroll Database

A SQL-based payroll and salary management system built with **SQLite**.

## What it does

PayrollDB manages employee compensation data across seven interconnected tables — departments, employees, salary history, payroll records, deductions, performance reviews, and bonuses.

## Schema

**7 tables &middot; 67 columns &middot; 21 indexes**

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

## Sample data

25 employees across 5 departments with realistic salary ranges ($55K–$210K), two months of payroll with itemized deductions, 20 performance reviews, and 15 bonuses.

## Queries

22 analytical queries organized into 8 categories:

- Employee directory and demographics
- Salary analysis and raise history
- Payroll reports and payment breakdowns
- Deduction summaries
- Performance analytics
- Bonus reports
- Department-level insights
- Advanced queries using CTEs and window functions

## Views & triggers

6 views for common lookups — employee summary, payroll detail, department dashboard, review summary, salary timeline, and total compensation.

7 triggers for automation — salary changes auto-log to history, `updated_at` stays current, termination dates set themselves, departments with employees can't be deleted, and deduction changes sync to payroll totals.

## Getting started

```bash
git clone https://github.com/yourusername/PayrollDB.git
cd PayrollDB
sqlite3 payroll.db < sql/01_schema.sql
sqlite3 payroll.db < sql/02_seed_data.sql
sqlite3 payroll.db < sql/04_views_triggers.sql
sqlite3 payroll.db < sql/03_queries.sql
```

## License

MIT — see [LICENSE](LICENSE) for details.