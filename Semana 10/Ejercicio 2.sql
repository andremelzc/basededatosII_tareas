-- En la sesión 1
UPDATE employees
SET salary = salary + 500
WHERE employee_id = 103; 

-- En la sesión 2
UPDATE employees
SET salary = salary + 100
WHERE employee_id = 103;

-- Vuelvo a la sesión 1
ROLLBACK;