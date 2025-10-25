SET SERVEROUTPUT ON;
BEGIN
    -- Aumenta 10% a empleados del departamento 90
    UPDATE employees
    SET salary = salary * 1.10
    WHERE department_id = 90; 
    
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' empleados actualizados en depto 90.');

    -- Guarda un punto de control
    SAVEPOINT punto1; 

    -- Aumenta 5% a empleados del departamento 60
    UPDATE employees
    SET salary = salary * 1.05
    WHERE department_id = 60;
    
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' empleados actualizados en depto 60.');

    -- Revierte los cambios HASTA el punto1
    ROLLBACK TO SAVEPOINT punto1; 
    DBMS_OUTPUT.PUT_LINE('Rollback a punto1 ejecutado.');

    -- Confirma la transacción
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('Transacción confirmada.');

END;
/