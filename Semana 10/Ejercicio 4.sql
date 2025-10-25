SET SERVEROUTPUT ON;
BEGIN
    -- Aumentar 8% a depto 100
    UPDATE employees 
    SET salary = salary * 1.08 
    WHERE department_id = 100;
    SAVEPOINT A; 
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' empleados actualizados en depto 100.');

    -- Aumentar 5% a depto 80
    UPDATE employees 
    SET salary = salary * 1.05 
    WHERE department_id = 80;
    SAVEPOINT B; 
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' empleados actualizados en depto 80.');

    -- Eliminar empleados depto 50
    DELETE FROM employees 
    WHERE department_id = 50; 
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' empleados eliminados en depto 50.');

    -- Revertir cambios hasta SAVEPOINT B
    ROLLBACK TO SAVEPOINT B; 
    DBMS_OUTPUT.PUT_LINE('Rollback a SAVEPOINT B ejecutado.');

    -- Confirmar transacción
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('Transacción confirmada.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/