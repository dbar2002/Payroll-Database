-- PayrollDB — Seed Data
-- sqlite3 payroll.db < sql/02_seed_data.sql

PRAGMA foreign_keys = ON;


-- departments (managers assigned after employees exist)

INSERT INTO departments (name, location, budget) VALUES
    ('Engineering',      'Building A - Floor 3',  2500000.00),
    ('Human Resources',  'Building A - Floor 1',   800000.00),
    ('Sales',            'Building B - Floor 2',  1800000.00),
    ('Marketing',        'Building B - Floor 1',  1200000.00),
    ('Finance',          'Building A - Floor 2',  1000000.00);


-- employees

INSERT INTO employees (first_name, last_name, email, phone, gender, address, date_of_birth, hire_date, job_title, department_id, employment_status, pay_frequency, base_salary) VALUES
    ('Marcus',   'Chen',       'marcus.chen@company.com',      '415-555-0101', 'male',   '742 Elm St, San Jose, CA 95112',         '1985-03-14', '2019-01-15', 'VP of Engineering',       1, 'active',    'monthly',      185000.00),
    ('Priya',    'Sharma',     'priya.sharma@company.com',     '415-555-0102', 'female', '1288 Oak Ave, Sunnyvale, CA 94086',      '1990-07-22', '2020-03-01', 'Senior Software Engineer',1, 'active',    'semi_monthly', 155000.00),
    ('James',    'Rodriguez',  'james.rodriguez@company.com',  '415-555-0103', 'male',   '456 Pine Rd, Santa Clara, CA 95050',     '1992-11-08', '2021-06-14', 'Software Engineer',       1, 'active',    'semi_monthly', 128000.00),
    ('Aisha',    'Patel',      'aisha.patel@company.com',      '415-555-0104', 'female', '891 Cedar Ln, Mountain View, CA 94040',  '1994-05-30', '2022-01-10', 'Software Engineer',       1, 'active',    'semi_monthly', 120000.00),
    ('Erik',     'Johansson',  'erik.johansson@company.com',   '415-555-0105', 'male',   '334 Birch Dr, Palo Alto, CA 94301',      '1988-09-17', '2020-08-03', 'DevOps Lead',             1, 'active',    'semi_monthly', 148000.00),
    ('Mei',      'Zhang',      'mei.zhang@company.com',        '415-555-0106', 'female', '567 Maple Ct, Cupertino, CA 95014',      '1993-12-01', '2023-02-20', 'Junior Developer',        1, 'probation', 'semi_monthly',  92000.00),
    ('David',    'Kim',        'david.kim@company.com',        '415-555-0107', 'male',   '223 Walnut Way, Milpitas, CA 95035',     '1991-04-25', '2021-09-01', 'QA Engineer',             1, 'active',    'semi_monthly', 110000.00),
    ('Sofia',    'Morales',    'sofia.morales@company.com',    '415-555-0108', 'female', '890 Spruce Ave, San Jose, CA 95125',     '1995-08-12', '2024-06-01', 'Intern',                  1, 'active',    'biweekly',      55000.00),

    ('Rachel',   'Thompson',   'rachel.thompson@company.com',  '415-555-0201', 'female', '112 Ash St, Campbell, CA 95008',         '1983-06-19', '2018-04-02', 'HR Director',             2, 'active',    'monthly',      145000.00),
    ('Omar',     'Hassan',     'omar.hassan@company.com',      '415-555-0202', 'male',   '445 Poplar Rd, Los Gatos, CA 95030',     '1989-01-11', '2020-11-16', 'HR Manager',              2, 'active',    'monthly',      115000.00),
    ('Lisa',     'Nguyen',     'lisa.nguyen@company.com',      '415-555-0203', 'female', '678 Willow Ln, Saratoga, CA 95070',      '1996-10-05', '2023-07-01', 'HR Coordinator',          2, 'active',    'semi_monthly',  72000.00),
    ('Tom',      'Baker',      'tom.baker@company.com',        '415-555-0204', 'male',   '901 Redwood Dr, San Jose, CA 95131',     '1987-02-28', '2019-09-15', 'Recruiter',               2, 'on_leave',  'semi_monthly',  85000.00),

    ('Daniel',   'Williams',   'daniel.williams@company.com',  '415-555-0301', 'male',   '234 Sequoia Blvd, Fremont, CA 94536',   '1984-08-07', '2017-06-01', 'Sales Director',          3, 'active',    'monthly',      165000.00),
    ('Amanda',   'Foster',     'amanda.foster@company.com',    '415-555-0302', 'female', '567 Cypress Ave, Newark, CA 94560',      '1991-03-15', '2021-01-11', 'Senior Account Exec',     3, 'active',    'monthly',      130000.00),
    ('Ryan',     'OConnor',    'ryan.oconnor@company.com',     '415-555-0303', 'male',   '890 Juniper Rd, Union City, CA 94587',   '1993-06-22', '2022-04-18', 'Account Executive',       3, 'active',    'monthly',      105000.00),
    ('Yuki',     'Tanaka',     'yuki.tanaka@company.com',      '415-555-0304', 'female', '123 Magnolia Way, Hayward, CA 94541',    '1990-12-09', '2020-07-20', 'Account Executive',       3, 'active',    'monthly',      108000.00),
    ('Carlos',   'Rivera',     'carlos.rivera@company.com',    '415-555-0305', 'male',   '456 Laurel St, Pleasanton, CA 94566',    '1986-04-03', '2019-02-25', 'Sales Manager',           3, 'active',    'monthly',      140000.00),
    ('Natasha',  'Volkov',     'natasha.volkov@company.com',   '415-555-0306', 'female', '789 Acacia Dr, Dublin, CA 94568',        '1997-07-18', '2024-01-08', 'Sales Rep',               3, 'probation', 'biweekly',      68000.00),

    ('Olivia',   'Bennett',    'olivia.bennett@company.com',   '415-555-0401', 'female', '321 Ivy Ln, Sunnyvale, CA 94087',        '1986-11-23', '2018-10-01', 'Marketing Director',      4, 'active',    'monthly',      155000.00),
    ('Kevin',    'Park',       'kevin.park@company.com',       '415-555-0402', 'male',   '654 Holly Ave, Santa Clara, CA 95051',   '1992-02-14', '2021-05-03', 'Content Strategist',      4, 'active',    'semi_monthly', 100000.00),
    ('Sarah',    'Mitchell',   'sarah.mitchell@company.com',   '415-555-0403', 'female', '987 Fern Ct, Cupertino, CA 95014',       '1994-09-27', '2022-08-15', 'Digital Marketing Spec',  4, 'active',    'semi_monthly',  88000.00),
    ('Andre',    'Dubois',     'andre.dubois@company.com',     '415-555-0404', 'male',   '147 Sage Dr, Mountain View, CA 94041',   '1998-01-06', '2024-03-01', 'Marketing Coordinator',   4, 'active',    'biweekly',      65000.00),

    ('Richard',  'Coleman',    'richard.coleman@company.com',  '415-555-0501', 'male',   '258 Sage Rd, San Jose, CA 95129',        '1980-05-10', '2016-03-01', 'CFO',                     5, 'active',    'monthly',      210000.00),
    ('Jennifer', 'Cruz',       'jennifer.cruz@company.com',    '415-555-0502', 'female', '369 Thyme St, Campbell, CA 95008',       '1988-08-19', '2019-11-04', 'Senior Accountant',       5, 'active',    'monthly',      115000.00),
    ('Nathan',   'Wright',     'nathan.wright@company.com',    '415-555-0503', 'male',   '481 Basil Ave, Los Gatos, CA 95032',     '1995-03-30', '2023-01-09', 'Financial Analyst',       5, 'active',    'semi_monthly',  90000.00);


-- assign department managers

UPDATE departments SET manager_id =  1 WHERE department_id = 1;
UPDATE departments SET manager_id =  9 WHERE department_id = 2;
UPDATE departments SET manager_id = 13 WHERE department_id = 3;
UPDATE departments SET manager_id = 19 WHERE department_id = 4;
UPDATE departments SET manager_id = 23 WHERE department_id = 5;


-- salary_history

INSERT INTO salary_history (employee_id, old_salary, new_salary, effective_date, change_reason, approved_by) VALUES
    ( 1,      0.00, 150000.00, '2019-01-15', 'hire',         NULL),
    ( 1, 150000.00, 165000.00, '2021-01-01', 'annual_raise',   23),
    ( 1, 165000.00, 185000.00, '2023-01-01', 'promotion',      23),
    ( 2,      0.00, 135000.00, '2020-03-01', 'hire',         NULL),
    ( 2, 135000.00, 145000.00, '2022-03-01', 'annual_raise',    1),
    ( 2, 145000.00, 155000.00, '2024-03-01', 'merit_raise',     1),
    ( 3,      0.00, 115000.00, '2021-06-14', 'hire',         NULL),
    ( 3, 115000.00, 128000.00, '2023-06-01', 'annual_raise',    1),
    ( 4,      0.00, 110000.00, '2022-01-10', 'hire',         NULL),
    ( 4, 110000.00, 120000.00, '2024-01-01', 'annual_raise',    1),
    ( 5,      0.00, 130000.00, '2020-08-03', 'hire',         NULL),
    ( 5, 130000.00, 140000.00, '2022-08-01', 'annual_raise',    1),
    ( 5, 140000.00, 148000.00, '2024-01-01', 'promotion',       1),
    ( 9,      0.00, 120000.00, '2018-04-02', 'hire',         NULL),
    ( 9, 120000.00, 130000.00, '2020-04-01', 'annual_raise',   23),
    ( 9, 130000.00, 145000.00, '2023-04-01', 'promotion',      23),
    (13,      0.00, 140000.00, '2017-06-01', 'hire',         NULL),
    (13, 140000.00, 150000.00, '2019-06-01', 'annual_raise',   23),
    (13, 150000.00, 165000.00, '2022-01-01', 'promotion',      23),
    (17,      0.00, 125000.00, '2019-02-25', 'hire',         NULL),
    (17, 125000.00, 140000.00, '2022-02-01', 'promotion',      13),
    (19,      0.00, 135000.00, '2018-10-01', 'hire',         NULL),
    (19, 135000.00, 145000.00, '2021-10-01', 'annual_raise',   23),
    (19, 145000.00, 155000.00, '2024-01-01', 'merit_raise',    23),
    (23,      0.00, 175000.00, '2016-03-01', 'hire',         NULL),
    (23, 175000.00, 190000.00, '2019-03-01', 'annual_raise',  NULL),
    (23, 190000.00, 210000.00, '2022-03-01', 'promotion',     NULL),
    (24,      0.00, 100000.00, '2019-11-04', 'hire',         NULL),
    (24, 100000.00, 115000.00, '2022-11-01', 'annual_raise',   23),
    ( 6,      0.00,  92000.00, '2023-02-20', 'hire',         NULL);


-- payroll (Jan + Feb 2026)

INSERT INTO payroll (employee_id, pay_period_start, pay_period_end, gross_salary, total_deductions, payment_date, payment_method, payment_status) VALUES
    ( 1, '2026-01-01', '2026-01-31', 15416.67, 4932.00, '2026-01-31', 'direct_deposit', 'paid'),
    ( 2, '2026-01-01', '2026-01-15',  6458.33, 1937.00, '2026-01-15', 'direct_deposit', 'paid'),
    ( 3, '2026-01-01', '2026-01-15',  5333.33, 1493.00, '2026-01-15', 'direct_deposit', 'paid'),
    ( 4, '2026-01-01', '2026-01-15',  5000.00, 1400.00, '2026-01-15', 'direct_deposit', 'paid'),
    ( 5, '2026-01-01', '2026-01-15',  6166.67, 1850.00, '2026-01-15', 'direct_deposit', 'paid'),
    ( 6, '2026-01-01', '2026-01-15',  3833.33, 1073.00, '2026-01-15', 'direct_deposit', 'paid'),
    ( 7, '2026-01-01', '2026-01-15',  4583.33, 1283.00, '2026-01-15', 'direct_deposit', 'paid'),
    ( 8, '2026-01-01', '2026-01-09',  2115.38,  550.00, '2026-01-09', 'direct_deposit', 'paid'),
    ( 9, '2026-01-01', '2026-01-31', 12083.33, 3867.00, '2026-01-31', 'direct_deposit', 'paid'),
    (10, '2026-01-01', '2026-01-31',  9583.33, 3067.00, '2026-01-31', 'direct_deposit', 'paid'),
    (11, '2026-01-01', '2026-01-15',  3000.00,  840.00, '2026-01-15', 'direct_deposit', 'paid'),
    (12, '2026-01-01', '2026-01-15',  3541.67,  991.00, '2026-01-15', 'check',          'paid'),
    (13, '2026-01-01', '2026-01-31', 13750.00, 4400.00, '2026-01-31', 'direct_deposit', 'paid'),
    (14, '2026-01-01', '2026-01-31', 10833.33, 3467.00, '2026-01-31', 'direct_deposit', 'paid'),
    (15, '2026-01-01', '2026-01-31',  8750.00, 2800.00, '2026-01-31', 'direct_deposit', 'paid'),
    (16, '2026-01-01', '2026-01-31',  9000.00, 2880.00, '2026-01-31', 'direct_deposit', 'paid'),
    (17, '2026-01-01', '2026-01-31', 11666.67, 3733.00, '2026-01-31', 'direct_deposit', 'paid'),
    (18, '2026-01-01', '2026-01-09',  2615.38,  680.00, '2026-01-09', 'direct_deposit', 'paid'),
    (19, '2026-01-01', '2026-01-31', 12916.67, 4133.00, '2026-01-31', 'direct_deposit', 'paid'),
    (20, '2026-01-01', '2026-01-15',  4166.67, 1167.00, '2026-01-15', 'direct_deposit', 'paid'),
    (21, '2026-01-01', '2026-01-15',  3666.67, 1027.00, '2026-01-15', 'direct_deposit', 'paid'),
    (22, '2026-01-01', '2026-01-09',  2500.00,  650.00, '2026-01-09', 'direct_deposit', 'paid'),
    (23, '2026-01-01', '2026-01-31', 17500.00, 5600.00, '2026-01-31', 'wire_transfer',  'paid'),
    (24, '2026-01-01', '2026-01-31',  9583.33, 3067.00, '2026-01-31', 'direct_deposit', 'paid'),
    (25, '2026-01-01', '2026-01-15',  3750.00, 1050.00, '2026-01-15', 'direct_deposit', 'paid'),

    ( 1, '2026-02-01', '2026-02-28', 15416.67, 4932.00, '2026-02-28', 'direct_deposit', 'paid'),
    ( 2, '2026-02-01', '2026-02-15',  6458.33, 1937.00, '2026-02-15', 'direct_deposit', 'paid'),
    ( 3, '2026-02-01', '2026-02-15',  5333.33, 1493.00, '2026-02-15', 'direct_deposit', 'paid'),
    ( 4, '2026-02-01', '2026-02-15',  5000.00, 1400.00, '2026-02-15', 'direct_deposit', 'paid'),
    ( 5, '2026-02-01', '2026-02-15',  6166.67, 1850.00, '2026-02-15', 'direct_deposit', 'paid'),
    ( 6, '2026-02-01', '2026-02-15',  3833.33, 1073.00, '2026-02-15', 'direct_deposit', 'paid'),
    ( 7, '2026-02-01', '2026-02-15',  4583.33, 1283.00, '2026-02-15', 'direct_deposit', 'paid'),
    ( 8, '2026-02-01', '2026-02-13',  2115.38,  550.00, '2026-02-13', 'direct_deposit', 'paid'),
    ( 9, '2026-02-01', '2026-02-28', 12083.33, 3867.00, '2026-02-28', 'direct_deposit', 'paid'),
    (10, '2026-02-01', '2026-02-28',  9583.33, 3067.00, '2026-02-28', 'direct_deposit', 'paid'),
    (11, '2026-02-01', '2026-02-15',  3000.00,  840.00, '2026-02-15', 'direct_deposit', 'paid'),
    (12, '2026-02-01', '2026-02-15',  3541.67,  991.00, '2026-02-15', 'check',          'paid'),
    (13, '2026-02-01', '2026-02-28', 13750.00, 4400.00, '2026-02-28', 'direct_deposit', 'paid'),
    (14, '2026-02-01', '2026-02-28', 10833.33, 3467.00, '2026-02-28', 'direct_deposit', 'paid'),
    (15, '2026-02-01', '2026-02-28',  8750.00, 2800.00, '2026-02-28', 'direct_deposit', 'paid'),
    (16, '2026-02-01', '2026-02-28',  9000.00, 2880.00, '2026-02-28', 'direct_deposit', 'paid'),
    (17, '2026-02-01', '2026-02-28', 11666.67, 3733.00, '2026-02-28', 'direct_deposit', 'paid'),
    (18, '2026-02-01', '2026-02-13',  2615.38,  680.00, '2026-02-13', 'direct_deposit', 'paid'),
    (19, '2026-02-01', '2026-02-28', 12916.67, 4133.00, '2026-02-28', 'direct_deposit', 'paid'),
    (20, '2026-02-01', '2026-02-15',  4166.67, 1167.00, '2026-02-15', 'direct_deposit', 'paid'),
    (21, '2026-02-01', '2026-02-15',  3666.67, 1027.00, '2026-02-15', 'direct_deposit', 'paid'),
    (22, '2026-02-01', '2026-02-13',  2500.00,  650.00, '2026-02-13', 'direct_deposit', 'paid'),
    (23, '2026-02-01', '2026-02-28', 17500.00, 5600.00, '2026-02-28', 'wire_transfer',  'paid'),
    (24, '2026-02-01', '2026-02-28',  9583.33, 3067.00, '2026-02-28', 'direct_deposit', 'paid'),
    (25, '2026-02-01', '2026-02-15',  3750.00, 1050.00, '2026-02-15', 'direct_deposit', 'paid');


-- deductions (January payroll)

INSERT INTO deductions (payroll_id, deduction_type, amount, description) VALUES
    (1, 'federal_tax', 2467.00, 'Federal income tax'), (1, 'state_tax', 925.00, 'CA state tax'),
    (1, 'social_security', 556.00, NULL), (1, 'medicare', 224.00, NULL),
    (1, 'health_insurance', 350.00, 'PPO family plan'), (1, 'retirement_401k', 410.00, NULL),

    (2, 'federal_tax', 968.00, NULL), (2, 'state_tax', 388.00, NULL),
    (2, 'social_security', 200.00, NULL), (2, 'medicare', 94.00, NULL),
    (2, 'health_insurance', 175.00, 'HMO individual'), (2, 'retirement_401k', 112.00, NULL),

    (3, 'federal_tax', 747.00, NULL), (3, 'state_tax', 320.00, NULL),
    (3, 'social_security', 165.00, NULL), (3, 'medicare', 77.00, NULL),
    (3, 'health_insurance', 175.00, NULL), (3, 'retirement_401k', 9.00, NULL),

    (4, 'federal_tax', 690.00, NULL), (4, 'state_tax', 300.00, NULL),
    (4, 'social_security', 155.00, NULL), (4, 'medicare', 73.00, NULL),
    (4, 'health_insurance', 175.00, NULL), (4, 'retirement_401k', 7.00, NULL),

    (5, 'federal_tax', 925.00, NULL), (5, 'state_tax', 370.00, NULL),
    (5, 'social_security', 191.00, NULL), (5, 'medicare', 89.00, NULL),
    (5, 'health_insurance', 175.00, NULL), (5, 'retirement_401k', 100.00, NULL),

    (6, 'federal_tax', 460.00, NULL), (6, 'state_tax', 230.00, NULL),
    (6, 'social_security', 119.00, NULL), (6, 'medicare', 56.00, NULL),
    (6, 'health_insurance', 175.00, NULL), (6, 'retirement_401k', 33.00, NULL),

    (7, 'federal_tax', 550.00, NULL), (7, 'state_tax', 275.00, NULL),
    (7, 'social_security', 142.00, NULL), (7, 'medicare', 66.00, NULL),
    (7, 'health_insurance', 175.00, NULL), (7, 'retirement_401k', 75.00, NULL),

    (8, 'federal_tax', 212.00, NULL), (8, 'state_tax', 106.00, NULL),
    (8, 'social_security', 66.00, NULL), (8, 'medicare', 31.00, NULL),
    (8, 'health_insurance', 135.00, NULL),

    (9, 'federal_tax', 1933.00, NULL), (9, 'state_tax', 725.00, NULL),
    (9, 'social_security', 449.00, NULL), (9, 'medicare', 175.00, NULL),
    (9, 'health_insurance', 350.00, 'PPO family plan'), (9, 'retirement_401k', 235.00, NULL),

    (10, 'federal_tax', 1533.00, NULL), (10, 'state_tax', 575.00, NULL),
    (10, 'social_security', 297.00, NULL), (10, 'medicare', 139.00, NULL),
    (10, 'health_insurance', 350.00, NULL), (10, 'retirement_401k', 173.00, NULL),

    (11, 'federal_tax', 360.00, NULL), (11, 'state_tax', 180.00, NULL),
    (11, 'social_security', 93.00, NULL), (11, 'medicare', 44.00, NULL),
    (11, 'health_insurance', 163.00, NULL),

    (12, 'federal_tax', 425.00, NULL), (12, 'state_tax', 213.00, NULL),
    (12, 'social_security', 110.00, NULL), (12, 'medicare', 51.00, NULL),
    (12, 'health_insurance', 175.00, NULL), (12, 'retirement_401k', 17.00, NULL),

    (13, 'federal_tax', 2200.00, NULL), (13, 'state_tax', 825.00, NULL),
    (13, 'social_security', 512.00, NULL), (13, 'medicare', 199.00, NULL),
    (13, 'health_insurance', 350.00, 'PPO family plan'), (13, 'retirement_401k', 314.00, NULL),

    (14, 'federal_tax', 1733.00, NULL), (14, 'state_tax', 650.00, NULL),
    (14, 'social_security', 403.00, NULL), (14, 'medicare', 157.00, NULL),
    (14, 'health_insurance', 350.00, NULL), (14, 'retirement_401k', 174.00, NULL),

    (15, 'federal_tax', 1400.00, NULL), (15, 'state_tax', 525.00, NULL),
    (15, 'social_security', 326.00, NULL), (15, 'medicare', 127.00, NULL),
    (15, 'health_insurance', 350.00, NULL), (15, 'retirement_401k', 72.00, NULL),

    (16, 'federal_tax', 1440.00, NULL), (16, 'state_tax', 540.00, NULL),
    (16, 'social_security', 335.00, NULL), (16, 'medicare', 131.00, NULL),
    (16, 'health_insurance', 350.00, NULL), (16, 'retirement_401k', 84.00, NULL),

    (17, 'federal_tax', 1867.00, NULL), (17, 'state_tax', 700.00, NULL),
    (17, 'social_security', 434.00, NULL), (17, 'medicare', 169.00, NULL),
    (17, 'health_insurance', 350.00, NULL), (17, 'retirement_401k', 213.00, NULL),

    (18, 'federal_tax', 262.00, NULL), (18, 'state_tax', 131.00, NULL),
    (18, 'social_security', 81.00, NULL), (18, 'medicare', 38.00, NULL),
    (18, 'health_insurance', 168.00, NULL),

    (19, 'federal_tax', 2067.00, NULL), (19, 'state_tax', 775.00, NULL),
    (19, 'social_security', 481.00, NULL), (19, 'medicare', 187.00, NULL),
    (19, 'health_insurance', 350.00, 'PPO family plan'), (19, 'retirement_401k', 273.00, NULL),

    (20, 'federal_tax', 500.00, NULL), (20, 'state_tax', 250.00, NULL),
    (20, 'social_security', 129.00, NULL), (20, 'medicare', 60.00, NULL),
    (20, 'health_insurance', 175.00, NULL), (20, 'retirement_401k', 53.00, NULL),

    (21, 'federal_tax', 440.00, NULL), (21, 'state_tax', 220.00, NULL),
    (21, 'social_security', 114.00, NULL), (21, 'medicare', 53.00, NULL),
    (21, 'health_insurance', 175.00, NULL), (21, 'retirement_401k', 25.00, NULL),

    (22, 'federal_tax', 250.00, NULL), (22, 'state_tax', 125.00, NULL),
    (22, 'social_security', 78.00, NULL), (22, 'medicare', 36.00, NULL),
    (22, 'health_insurance', 161.00, NULL),

    (23, 'federal_tax', 2800.00, NULL), (23, 'state_tax', 1050.00, NULL),
    (23, 'social_security', 650.00, NULL), (23, 'medicare', 254.00, NULL),
    (23, 'health_insurance', 350.00, 'PPO family plan'), (23, 'retirement_401k', 350.00, NULL),
    (23, 'hsa', 146.00, NULL),

    (24, 'federal_tax', 1533.00, NULL), (24, 'state_tax', 575.00, NULL),
    (24, 'social_security', 297.00, NULL), (24, 'medicare', 139.00, NULL),
    (24, 'health_insurance', 350.00, NULL), (24, 'retirement_401k', 173.00, NULL),

    (25, 'federal_tax', 450.00, NULL), (25, 'state_tax', 225.00, NULL),
    (25, 'social_security', 116.00, NULL), (25, 'medicare', 54.00, NULL),
    (25, 'health_insurance', 175.00, NULL), (25, 'retirement_401k', 30.00, NULL);


-- performance_reviews

INSERT INTO performance_reviews (employee_id, reviewer_id, review_date, review_period, rating, status, comments, goals) VALUES
    ( 2,  1, '2025-12-15', 'annual', 5, 'acknowledged', 'Exceptional technical leadership. Led migration to microservices ahead of schedule.', 'Lead cross-team initiative; mentor 2 junior engineers'),
    ( 3,  1, '2025-12-15', 'annual', 4, 'acknowledged', 'Strong contributor. Consistently delivers clean, well-tested code.', 'Take ownership of a system design doc'),
    ( 4,  1, '2025-12-15', 'annual', 4, 'acknowledged', 'Solid first full year. Ramped quickly and contributes to code reviews.', 'Deepen expertise in distributed systems'),
    ( 5,  1, '2025-12-15', 'annual', 5, 'acknowledged', 'Outstanding DevOps leadership. Reduced deployment time by 60%.', 'Implement chaos engineering practices'),
    ( 7,  1, '2025-12-15', 'annual', 3, 'acknowledged', 'Meets expectations. Good test coverage but could improve automation scope.', 'Automate regression suite'),
    ( 6,  1, '2025-12-15', 'probation', 4, 'submitted', 'Strong start for a junior developer. Shows initiative.', 'Complete onboarding project'),
    (10,  9, '2025-12-20', 'annual', 4, 'acknowledged', 'Effective people management. Successfully rolled out new benefits program.', 'Streamline onboarding; reduce time-to-hire by 15%'),
    (11,  9, '2025-12-20', 'annual', 3, 'acknowledged', 'Good coordination skills but needs more strategic thinking.', 'Lead a benefits analysis project independently'),
    (14, 13, '2025-12-18', 'annual', 5, 'acknowledged', 'Top performer. Exceeded quota by 135%. Landed 3 enterprise accounts.', 'Mentor new sales reps'),
    (15, 13, '2025-12-18', 'annual', 3, 'acknowledged', 'Met quota but inconsistent monthly performance.', 'Maintain 3x pipeline coverage'),
    (16, 13, '2025-12-18', 'annual', 4, 'acknowledged', 'Consistent performer. Good client relationships and strong renewals.', 'Expand into 2 new verticals'),
    (17, 13, '2025-12-18', 'annual', 4, 'acknowledged', 'Strong team leadership. Coaches reps effectively.', 'Develop sales enablement materials'),
    (18, 13, '2025-12-18', 'probation', 3, 'submitted', 'Meeting basic targets but still learning the product.', 'Pass product certification'),
    (20, 19, '2025-12-19', 'annual', 4, 'acknowledged', 'Excellent content strategy. Blog traffic up 45% YoY.', 'Launch video content series'),
    (21, 19, '2025-12-19', 'annual', 4, 'acknowledged', 'Strong digital campaigns. Improved paid ad ROAS by 28%.', 'Expand into new channels'),
    (24, 23, '2025-12-17', 'annual', 5, 'acknowledged', 'Exceptional accuracy. Identified $340K in cost savings through audit.', 'Lead annual budget process'),
    (25, 23, '2025-12-17', 'annual', 4, 'acknowledged', 'Good analytical skills. Models are accurate and well-documented.', 'Develop forecasting dashboard'),
    ( 2,  1, '2025-10-15', 'Q4', 5, 'acknowledged', 'On track for annual goals. Microservices Phase 2 nearing completion.', NULL),
    (14, 13, '2025-10-15', 'Q4', 5, 'acknowledged', 'Already at 120% of annual quota with one quarter remaining.', NULL),
    (24, 23, '2025-10-15', 'Q4', 4, 'acknowledged', 'Year-end close prep going smoothly.', NULL);


-- bonuses

INSERT INTO bonuses (employee_id, amount, bonus_type, date_awarded, reason, review_id, approved_by) VALUES
    ( 2, 15000.00, 'performance', '2026-01-15', 'Annual bonus — exceptional rating',          1,  1),
    ( 5, 12000.00, 'performance', '2026-01-15', 'Annual bonus — outstanding DevOps work',     4,  1),
    (14, 18000.00, 'performance', '2026-01-15', 'Annual bonus — 135% quota achievement',      9, 13),
    (24, 10000.00, 'performance', '2026-01-15', 'Annual bonus — cost savings identification', 16, 23),
    (16,  8000.00, 'performance', '2026-01-15', 'Annual bonus — consistent delivery',        11, 13),
    (20,  7500.00, 'performance', '2026-01-15', 'Annual bonus — content growth',             14, 19),
    ( 6, 10000.00, 'signing',     '2023-02-20', 'New hire signing bonus',                   NULL,  1),
    (18,  5000.00, 'signing',     '2024-01-08', 'New hire signing bonus',                   NULL, 13),
    (22,  3000.00, 'signing',     '2024-03-01', 'New hire signing bonus',                   NULL, 19),
    ( 1,  2500.00, 'holiday',     '2025-12-20', 'Year-end holiday bonus',                   NULL, 23),
    ( 9,  2500.00, 'holiday',     '2025-12-20', 'Year-end holiday bonus',                   NULL, 23),
    (13,  2500.00, 'holiday',     '2025-12-20', 'Year-end holiday bonus',                   NULL, 23),
    (19,  2500.00, 'holiday',     '2025-12-20', 'Year-end holiday bonus',                   NULL, 23),
    (23,  2500.00, 'holiday',     '2025-12-20', 'Year-end holiday bonus',                   NULL, NULL),
    ( 3,  2000.00, 'spot',        '2025-09-10', 'Critical bug fix during production outage', NULL,  1);