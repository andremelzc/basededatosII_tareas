SET SERVEROUTPUT ON;
DECLARE
    v_employee_id       employees.employee_id%TYPE := 104; [cite: 182]
    v_new_department_id employees.department_id%TYPE := 110; [cite: 182]
    v_old_department_id employees.department_id%TYPE;
    v_job_id            employees.job_id%TYPE;
    v_hire_date         employees.hire_date%TYPE;
BEGIN
    -- 1. Obtener datos actuales del empleado para el historial
    SELECT department_id, job_id, hire_date
    INTO v_old_department_id, v_job_id, v_hire_date
    FROM employees
    WHERE employee_id = v_employee_id
    FOR UPDATE; -- Bloquea la fila para esta transacción

    -- 2. Actualizar el departamento del empleado
    UPDATE employees
    SET department_id = v_new_department_id
    WHERE employee_id = v_employee_id; [cite: 182]

    -- 3. Insertar el registro en el historial (registrando el trabajo anterior)
    -- Asumimos que el trabajo anterior termina hoy (SYSDATE)
    -- y que comenzó en su fecha de contratación (v_hire_date).
    INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
    VALUES (v_employee_id, v_hire_date, SYSDATE, v_job_id, v_old_department_id); [cite: 183]

    -- 4. Si todo fue exitoso, confirmar
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transferencia del empleado ' || v_employee_id || ' completada.');

EXCEPTION
    WHEN OTHERS THEN
        -- 5. Si ocurre cualquier error, deshacer todo
        ROLLBACK; [cite: 184]
        DBMS_OUTPUT.PUT_LINE('Error en la transferencia. ' || SQLERRM); [cite: 184]
END;
/