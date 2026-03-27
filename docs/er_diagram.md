# Entity-Relationship Diagram

## Overview

PayrollDB uses 7 tables organized around the central `employees` table.

```
departments ──< employees ──< salary_history
                    │
                    ├──< payroll ──< deductions
                    │
                    ├──< performance_reviews
                    │
                    └──< bonuses (optionally linked to reviews)
```

## Relationships

| Parent | Child | Cardinality | FK Column | On Delete |
|--------|-------|-------------|-----------|-----------|
| departments | employees | 1 : N | department_id | RESTRICT |
| employees | departments | 1 : 0..1 | manager_id | SET NULL |
| employees | salary_history | 1 : N | employee_id | CASCADE |
| employees | payroll | 1 : N | employee_id | CASCADE |
| employees | performance_reviews | 1 : N | employee_id | CASCADE |
| employees | bonuses | 1 : N | employee_id | CASCADE |
| payroll | deductions | 1 : N | payroll_id | CASCADE |
| performance_reviews | bonuses | 1 : 0..N | review_id | SET NULL |
| employees | performance_reviews (reviewer) | 1 : N | reviewer_id | SET NULL |

## Circular Reference

`departments.manager_id` → `employees.employee_id` creates a circular
dependency with `employees.department_id` → `departments.department_id`.
This is resolved by making `manager_id` nullable and deferring its
assignment until after both tables have data.

## Computed Columns

- `salary_history.change_percentage` — auto-calculated from old/new salary
- `payroll.net_salary` — auto-calculated as gross minus deductions
