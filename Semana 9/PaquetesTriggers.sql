--------------------------------------------------------------------------------
-- 3.1. PAQUETE PARA OBJETO EMPLOYEE
-- Contiene los procedimientos y funciones CRUD requeridos,
-- además de los ejercicios solicitados del 3.1.1 al 3.1.4.
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE EMPLOYEE_PKG AS

  -------------------------------------------------------------------------------
  -- 3.1.1. Procedimiento que muestra los 4 empleados que más han rotado de puesto
  -- desde que ingresaron a la empresa, mostrando su código, nombre, apellido,
  -- código y nombre del puesto actual, y número de rotaciones.
  -------------------------------------------------------------------------------
  PROCEDURE empleados_mas_rotados(p_cantidad IN INT);

  -------------------------------------------------------------------------------
  -- 3.1.2. Función que muestra el resumen estadístico del número promedio de
  -- contrataciones por mes, con respecto a todos los años registrados.
  -- Devuelve el total de meses considerados.
  -------------------------------------------------------------------------------
  FUNCTION promedio_contrataciones_mensuales RETURN NUMBER;

  -------------------------------------------------------------------------------
  -- 3.1.3. Procedimiento que muestra el gasto total de salarios y estadísticas
  -- de empleados por región, incluyendo el salario total, cantidad de empleados
  -- y fecha del empleado más antiguo.
  -------------------------------------------------------------------------------
  PROCEDURE gastos_estadistica_regional;

  -------------------------------------------------------------------------------
  -- 3.1.4. Función que calcula el tiempo de servicio de cada empleado y el total
  -- de meses acumulados por vacaciones.
  -------------------------------------------------------------------------------
  FUNCTION tiempo_servicio RETURN NUMBER;

END EMPLOYEE_PKG;
/
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY EMPLOYEE_PKG IS

  -------------------------------------------------------------------------------
  -- 3.1.1. Procedimiento: empleados_mas_rotados
  -------------------------------------------------------------------------------
  PROCEDURE empleados_mas_rotados(p_cantidad IN INT) AS
    CURSOR emple_cur IS
      SELECT 
          E.EMPLOYEE_ID AS codigo,
          E.LAST_NAME AS apellido,
          E.FIRST_NAME AS nombre,
          J.JOB_ID AS codigo_puesto,
          J.JOB_TITLE AS nombre_puesto,
          COUNT(JH.JOB_ID) AS cantidad_rotaciones
      FROM EMPLOYEES E
      JOIN JOB_HISTORY JH ON E.EMPLOYEE_ID = JH.EMPLOYEE_ID
      JOIN JOBS J ON E.JOB_ID = J.JOB_ID
      GROUP BY E.EMPLOYEE_ID, E.LAST_NAME, E.FIRST_NAME, J.JOB_ID, J.JOB_TITLE
      ORDER BY cantidad_rotaciones DESC
      FETCH FIRST p_cantidad ROWS ONLY;
  BEGIN
      FOR rec IN emple_cur LOOP
          DBMS_OUTPUT.PUT_LINE(
              'Codigo: ' || rec.codigo || ', ' ||
              'Apellido: ' || rec.apellido || ', ' ||
              'Nombre: ' || rec.nombre || ', ' ||
              'Codigo del puesto: ' || rec.codigo_puesto || ', ' ||
              'Nombre del puesto: ' || rec.nombre_puesto || ', ' ||
              'Cantidad de rotaciones: ' || rec.cantidad_rotaciones
          );
      END LOOP;
  END empleados_mas_rotados;

  -------------------------------------------------------------------------------
  -- 3.1.2. Función: promedio_contrataciones_mensuales
  -------------------------------------------------------------------------------
  FUNCTION promedio_contrataciones_mensuales RETURN NUMBER AS
      v_total_meses NUMBER := 0;
  BEGIN
      DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Resumen Estadístico de Contrataciones ---');
      DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('Nombre del Mes | Número Promedio de Contrataciones');
      DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

      FOR rec IN (
          WITH Contrataciones_por_Mes_Ano AS (
              SELECT
                  EXTRACT(MONTH FROM HIRE_DATE) AS mes_num,
                  TO_CHAR(HIRE_DATE, 'Month') AS mes_nombre, 
                  COUNT(EMPLOYEE_ID) AS total_contrataciones
              FROM EMPLOYEES
              GROUP BY
                  EXTRACT(YEAR FROM HIRE_DATE), EXTRACT(MONTH FROM HIRE_DATE), TO_CHAR(HIRE_DATE, 'Month')
          )
          SELECT
              c.mes_nombre,
              AVG(c.total_contrataciones) AS promedio_contrataciones_mes
          FROM Contrataciones_por_Mes_Ano c
          GROUP BY c.mes_nombre, c.mes_num
          ORDER BY c.mes_num
      ) LOOP
          DBMS_OUTPUT.PUT_LINE(RPAD(rec.mes_nombre, 15) || ' | ' || TO_CHAR(rec.promedio_contrataciones_mes, '99.00'));
          v_total_meses := v_total_meses + 1;
      END LOOP;

      DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('Total de meses en el listado: ' || v_total_meses);
      RETURN v_total_meses;
  END promedio_contrataciones_mensuales;

  -------------------------------------------------------------------------------
  -- 3.1.3. Procedimiento: gastos_estadistica_regional
  -------------------------------------------------------------------------------
  PROCEDURE gastos_estadistica_regional IS
    CURSOR c_region_est IS
      SELECT 
          R.REGION_NAME AS region,
          SUM(E.SALARY) AS salario_total,
          COUNT(E.EMPLOYEE_ID) AS cantidad_empleados,
          MIN(E.HIRE_DATE) AS fecha_empleado_antiguo
      FROM REGIONS R
      JOIN COUNTRIES C USING(REGION_ID)
      JOIN LOCATIONS L USING(COUNTRY_ID)
      JOIN DEPARTMENTS D USING(LOCATION_ID)
      JOIN EMPLOYEES E USING(DEPARTMENT_ID)
      GROUP BY R.REGION_NAME;
  BEGIN
      DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Reporte de Gastos y Estadística Regional ---');
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('Región           | Suma Salarios   | Cantidad Empleados | Empleado Más Antiguo (Fecha Ingreso)');
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------------');

      FOR rec IN c_region_est LOOP
          DBMS_OUTPUT.PUT_LINE(
              RPAD(rec.region, 17) || ' | ' ||
              RPAD(TO_CHAR(rec.salario_total, 'FM999,999.00'), 15) || ' | ' ||
              RPAD(TO_CHAR(rec.cantidad_empleados), 18) || ' | ' ||
              TO_CHAR(rec.fecha_empleado_antiguo, 'DD-MON-YYYY')
          );
      END LOOP;
  END gastos_estadistica_regional;

  -------------------------------------------------------------------------------
  -- 3.1.4. Función: tiempo_servicio
  -------------------------------------------------------------------------------
  FUNCTION tiempo_servicio RETURN NUMBER IS
      v_monto_total INT := 0;
  BEGIN
      DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Tiempo de Servicio de Empleados ---');
      DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('Cod | Nombre Completo     | Años Servicio | Meses Vacaciones');
      DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

      FOR rec IN (
          SELECT 
              EMPLOYEE_ID AS codigo,
              FIRST_NAME || ' ' || LAST_NAME AS nombre_completo,
              HIRE_DATE AS fecha_contrato,
              MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12 AS tiempo_servicio_anos,
              TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) AS meses_vacaciones
          FROM EMPLOYEES
          ORDER BY EMPLOYEE_ID  
      ) LOOP
          DBMS_OUTPUT.PUT_LINE(
              RPAD(rec.codigo, 3) || ' | ' ||
              RPAD(rec.nombre_completo, 18) || ' | ' ||
              RPAD(TO_CHAR(rec.tiempo_servicio_anos, '99.00'), 22) || ' | ' ||
              TO_CHAR(rec.meses_vacaciones)
          );
          v_monto_total := v_monto_total + rec.meses_vacaciones;
      END LOOP;

      DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('MONTO TOTAL EMPLEADO PARA EL TIEMPO DE SERVICIOS (MESES): ' || v_monto_total);
      RETURN v_monto_total;
  END tiempo_servicio;

END EMPLOYEE_PKG;
/

--------------------------------------------------------------------------------
-- 3.1.5. FUNCIÓN: fn_obtener_horas_trabajo_mes
-- Descripción:
--   Calcula la cantidad de horas que un empleado ha trabajado en un mes y año
--   determinados, usando la tabla ASISTENCIA_EMPLEADO.
-- Parámetros:
--   p_EMPLOYEE_ID → Código del empleado
--   p_MONTH       → Número del mes
--   p_YEAR        → Año
-- Retorna:
--   El número total de horas trabajadas por el empleado en el mes indicado.
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_obtener_horas_trabajo_mes(
    p_EMPLOYEE_ID INT,
    p_MONTH       INT,
    p_YEAR        INT
)
RETURN NUMBER
IS
    v_horas_trabajo NUMBER;
BEGIN
    SELECT
        SUM((CAST(hora_termino_real AS DATE) - CAST(hora_inicio_real AS DATE)) * 24)
    INTO
        v_horas_trabajo
    FROM
        ASISTENCIA_EMPLEADO
    WHERE
        EXTRACT(MONTH FROM fecha_real) = p_MONTH
        AND EXTRACT(YEAR FROM fecha_real) = p_YEAR
        AND employee_id = p_EMPLOYEE_ID;

    RETURN NVL(v_horas_trabajo, 0);
END fn_obtener_horas_trabajo_mes;
/
--------------------------------------------------------------------------------
-- 3.1.6. FUNCIÓN: fn_obtener_horas_faltantes
-- Descripción:
--   Calcula la cantidad de horas que un empleado faltó en un mes y año
--   determinados. Utiliza la función 3.1.5 (fn_obtener_horas_trabajo_mes)
--   para conocer las horas trabajadas reales.
-- Parámetros:
--   p_employee_id → Código del empleado
--   p_mes         → Número del mes
--   p_anio        → Año
-- Retorna:
--   El número de horas que el empleado faltó en el mes.
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_obtener_horas_faltantes(
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE,
    p_mes         IN NUMBER,
    p_anio        IN NUMBER
)
RETURN NUMBER
IS
    v_horas_laboradas_reales    NUMBER;
    v_horas_teoricas_semanales  NUMBER;
    v_horas_teoricas_mensuales  NUMBER;
    v_horas_faltantes           NUMBER;
    v_dias_mes                  NUMBER;
BEGIN
    -- 1️⃣ Calcular el número de días del mes
    v_dias_mes := EXTRACT(DAY FROM LAST_DAY(TO_DATE(p_anio || '-' || p_mes, 'YYYY-MM')));

    -- 2️⃣ Calcular las horas teóricas semanales (INTERVAL → horas numéricas)
    SELECT 
        NVL(SUM(
            EXTRACT(DAY FROM (H.hora_termino - H.hora_inicio)) * 24 +
            EXTRACT(HOUR FROM (H.hora_termino - H.hora_inicio)) +
            (EXTRACT(MINUTE FROM (H.hora_termino - H.hora_inicio)) / 60) +
            (EXTRACT(SECOND FROM (H.hora_termino - H.hora_inicio)) / 3600)
        ), 0)
    INTO 
        v_horas_teoricas_semanales
    FROM 
        EMPLEADO_HORARIO EH
        JOIN HORARIO H USING(dia_de_la_semana, turno)
    WHERE 
        EH.employee_id = p_employee_id;

    -- 3️⃣ Calcular horas teóricas mensuales (semanales * días/7)
    v_horas_teoricas_mensuales := v_horas_teoricas_semanales * (v_dias_mes / 7);

    -- 4️⃣ Calcular horas laboradas reales (llamando a función 3.1.5)
    v_horas_laboradas_reales := fn_obtener_horas_trabajo_mes(p_employee_id, p_mes, p_anio);

    -- 5️⃣ Calcular horas faltantes
    v_horas_faltantes := v_horas_teoricas_mensuales - v_horas_laboradas_reales;

    -- 6️⃣ Evitar valores negativos
    RETURN GREATEST(v_horas_faltantes, 0);
END fn_obtener_horas_faltantes;
/
--------------------------------------------------------------------------------
-- 3.1.7. PROCEDIMIENTO: reporte_salario_empleado
-- Descripción:
--   Calcula y muestra el salario ajustado de cada empleado en función de las
--   horas trabajadas y las horas faltadas en un mes determinado.
--   Utiliza las funciones 3.1.5 y 3.1.6.
-- Parámetros:
--   p_mes  → Número del mes
--   p_anio → Año
-- Salida:
--   Muestra un reporte con el nombre, salario base, horas faltadas y salario final.
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE reporte_salario_empleado(
    p_mes  IN NUMBER,
    p_anio IN NUMBER
)
IS
    CURSOR c_salario_empleado IS
        SELECT 
            EMPLOYEE_ID AS codigo,
            FIRST_NAME AS nombre,
            LAST_NAME AS apellido,
            SALARY AS salario
        FROM EMPLOYEES;

    v_horas_faltadas           NUMBER;
    v_horas_teoricas_semanales NUMBER;
    v_horas_teoricas_mes       NUMBER;
    v_valor_hora               NUMBER;
    v_salario_ajustado         NUMBER;
    v_dias_mes                 NUMBER;
BEGIN
    -- Calcular total de días del mes
    v_dias_mes := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(p_anio || '-' || p_mes, 'YYYY-MM')), 'DD'));

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- REPORTE DE SALARIO AJUSTADO (' || p_mes || '/' || p_anio || ') ---');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Empleado              | Salario Base | Horas Faltadas | Salario Final');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------');

    FOR rec IN c_salario_empleado LOOP
        -- Obtener horas faltadas (función 3.1.6)
        v_horas_faltadas := NVL(fn_obtener_horas_faltantes(rec.codigo, p_mes, p_anio), 0);

        BEGIN
            -- Calcular horas teóricas semanales
            SELECT 
                NVL(SUM(
                    EXTRACT(DAY FROM (H.hora_termino - H.hora_inicio)) * 24 +
                    EXTRACT(HOUR FROM (H.hora_termino - H.hora_inicio)) +
                    (EXTRACT(MINUTE FROM (H.hora_termino - H.hora_inicio)) / 60) +
                    (EXTRACT(SECOND FROM (H.hora_termino - H.hora_inicio)) / 3600)
                ), 0)
            INTO 
                v_horas_teoricas_semanales
            FROM 
                EMPLEADO_HORARIO EH
                JOIN HORARIO H USING(dia_de_la_semana, turno)
            WHERE 
                EH.employee_id = rec.codigo;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_horas_teoricas_semanales := 0;
        END;

        -- Calcular horas teóricas mensuales
        v_horas_teoricas_mes := v_horas_teoricas_semanales * (v_dias_mes / 7);

        -- Calcular salario ajustado
        IF v_horas_teoricas_mes <= 0 OR rec.salario IS NULL THEN
            v_salario_ajustado := NVL(rec.salario, 0);
        ELSE
            v_valor_hora := rec.salario / v_horas_teoricas_mes;

            IF v_horas_faltadas > 0 THEN
                v_salario_ajustado := rec.salario - (v_horas_faltadas * v_valor_hora);
            ELSE
                v_salario_ajustado := rec.salario;
            END IF;

            v_salario_ajustado := GREATEST(v_salario_ajustado, 0);
        END IF;

        -- Mostrar reporte
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(rec.nombre || ' ' || rec.apellido, 1, 20), 20) || ' | ' ||
            RPAD(TO_CHAR(NVL(rec.salario, 0), 'FM9,999.00'), 12) || ' | ' ||
            RPAD(TO_CHAR(v_horas_faltadas, '99.00'), 14) || ' | ' ||
            TO_CHAR(v_salario_ajustado, 'FM9,999.00')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------');
END reporte_salario_empleado;
/

--------------------------------------------------------------------------------
-- 3.1.1. Función: fn_total_horas_capacitacion
-- Retorna: total de horas de capacitación que tiene un empleado
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_total_horas_capacitacion(
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE
) RETURN NUMBER
IS
    v_total_horas NUMBER;
BEGIN
    SELECT NVL(SUM(c.horas_capacitacion),0)
    INTO v_total_horas
    FROM empleado_capacitacion ec
    JOIN capacitacion c ON ec.capacitacion_id = c.capacitacion_id
    WHERE ec.employee_id = p_employee_id;

    RETURN v_total_horas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END fn_total_horas_capacitacion;
/

--------------------------------------------------------------------------------
-- 3.1.2. Procedimiento: listar_capacitaciones_empleados
-- Muestra: por cada empleado, total de horas de capacitación (ordenado desc por total).
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE listar_capacitaciones_empleados
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Capacitaciones y Horas por Empleado ---');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Empleado ID | Nombre Completo           | Horas Totales');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');

    FOR rec IN (
        SELECT
            e.employee_id,
            e.first_name || ' ' || e.last_name AS nombre_completo,
            NVL(SUM(c.horas_capacitacion),0) AS horas_totales
        FROM employees e
        LEFT JOIN empleado_capacitacion ec ON e.employee_id = ec.employee_id
        LEFT JOIN capacitacion c ON ec.capacitacion_id = c.capacitacion_id
        GROUP BY e.employee_id, e.first_name, e.last_name
        ORDER BY horas_totales DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.employee_id, 11) || ' | ' ||
                             RPAD(rec.nombre_completo, 24) || ' | ' ||
                             TO_CHAR(rec.horas_totales, 'FM9990'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
END listar_capacitaciones_empleados;
/

--------------------------------------------------------------------------------
-- 3.2. Trigger: trg_validar_asistencia
-- BEFORE INSERT OR UPDATE on ASISTENCIA_EMPLEADO
-- Valida: día de la semana y correspondencia con horario asignado.
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_validar_asistencia
BEFORE INSERT OR UPDATE ON asistencia_empleado
FOR EACH ROW
DECLARE
    v_weekday_name   VARCHAR2(20);
    v_weekday_num    VARCHAR2(1);
    v_cnt            NUMBER;
    -- variables para comparar horarios
    v_hora_inicio_sched   INTERVAL DAY TO SECOND := NULL; -- si es INTERVAL
    v_hora_termino_sched  INTERVAL DAY TO SECOND := NULL;
    v_hora_inicio_ok      BOOLEAN := FALSE;
    v_hora_termino_ok     BOOLEAN := FALSE;
BEGIN
    -- 1) Normalizar nombre del día en español (p.ej. 'LUNES')
    v_weekday_name := TRIM(UPPER(TO_CHAR(:NEW.fecha_real, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));

    -- 2) También obtener número de día (1..7) para el caso en que la columna guarde número
    v_weekday_num := TO_CHAR(:NEW.fecha_real, 'D');

    -- 3) Verificar que exista un horario asignado para ese empleado y ese día
    SELECT COUNT(*) INTO v_cnt
    FROM empleado_horario eh
      JOIN horario h ON (eh.dia_de_la_semana = h.dia_de_la_semana AND eh.turno = h.turno)
    WHERE eh.employee_id = :NEW.employee_id
      AND (
           UPPER(h.dia_de_la_semana) = v_weekday_name          -- caso día textual ('LUNES')
           OR h.dia_de_la_semana = v_weekday_num               -- caso día numérico ('1')
      );

    IF v_cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20020,
            'La fecha no corresponde al día de la semana del horario asignado al empleado.');
    END IF;

    -- 4) Verificar correspondencia de horas (tolerancia configurable)
    --    Aquí intentamos comparar la hora registrada con la hora programada.
    --    Ajusta según el tipo de datos de H.hora_inicio / H.hora_termino (INTERVAL, DATE, TIMESTAMP o VARCHAR2).

    FOR rec IN (
        SELECT h.hora_inicio, h.hora_termino
        FROM empleado_horario eh
        JOIN horario h ON (eh.dia_de_la_semana = h.dia_de_la_semana AND eh.turno = h.turno)
        WHERE eh.employee_id = :NEW.employee_id
          AND (UPPER(h.dia_de_la_semana) = v_weekday_name OR h.dia_de_la_semana = v_weekday_num)
    ) LOOP
        BEGIN
            -- Caso A: si horario almacenado es INTERVAL DAY TO SECOND (duración o time-of-day en interval)
            -- Convertimos a número de horas mediante EXTRACT. Si falla, caerá al EXCEPTION y probamos otra forma.
            v_hora_inicio_sched := rec.hora_inicio;
            v_hora_termino_sched := rec.hora_termino;

            -- comparar diferencia absoluta en horas entre horario y registro (INTENTADO)
            IF ( (EXTRACT(DAY FROM (:NEW.hora_inicio_real - v_hora_inicio_sched)) * 24
                   + EXTRACT(HOUR FROM (:NEW.hora_inicio_real - v_hora_inicio_sched))
                   + EXTRACT(MINUTE FROM (:NEW.hora_inicio_real - v_hora_inicio_sched)) / 60) BETWEEN -1 AND 1 )
            THEN
                v_hora_inicio_ok := TRUE;
            END IF;

            IF ( (EXTRACT(DAY FROM (:NEW.hora_termino_real - v_hora_termino_sched)) * 24
                   + EXTRACT(HOUR FROM (:NEW.hora_termino_real - v_hora_termino_sched))
                   + EXTRACT(MINUTE FROM (:NEW.hora_termino_real - v_hora_termino_sched)) / 60) BETWEEN -1 AND 1 )
            THEN
                v_hora_termino_ok := TRUE;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- no hacemos nada, probamos con otra conversión abajo
        END;

        -- Caso B: si horario almacenado es TIME/TIMESTAMP/DATE o VARCHAR con formato 'HH24:MI(:SS)'
        -- Intentamos convertir horario programado a DATE concatenándolo con la fecha de la asistencia para comparar.
        IF NOT v_hora_inicio_ok OR NOT v_hora_termino_ok THEN
            BEGIN
                DECLARE
                    v_sched_start_dt DATE;
                    v_sched_end_dt   DATE;
                    v_reg_start_dt   DATE := NULL;
                    v_reg_end_dt     DATE := NULL;
                BEGIN
                    -- Si h.hora_inicio y h.hora_termino están en formato VARCHAR2 'HH24:MI' o 'HH24:MI:SS'
                    v_sched_start_dt := TO_DATE(TO_CHAR(:NEW.fecha_real,'YYYY-MM-DD') || ' ' || TO_CHAR(rec.hora_inicio), 'YYYY-MM-DD HH24:MI:SS');
                    v_sched_end_dt   := TO_DATE(TO_CHAR(:NEW.fecha_real,'YYYY-MM-DD') || ' ' || TO_CHAR(rec.hora_termino), 'YYYY-MM-DD HH24:MI:SS');

                    -- Registrar hora real (si es TIMESTAMP/DATE convertir a DATE)
                    v_reg_start_dt := CAST(:NEW.hora_inicio_real AS DATE);
                    v_reg_end_dt   := CAST(:NEW.hora_termino_real AS DATE);

                    -- Permitimos tolerancia de 1 hora (ajusta si quieres 30 minutos => 0.5/24)
                    IF ABS((v_reg_start_dt - v_sched_start_dt) * 24) <= 1 THEN
                        v_hora_inicio_ok := TRUE;
                    END IF;
                    IF ABS((v_reg_end_dt - v_sched_end_dt) * 24) <= 1 THEN
                        v_hora_termino_ok := TRUE;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL; -- si falla conversión, no marcamos ok; se seguirá probando con otros registros
                END;
            END;
        END IF;

        -- Si alguna coincidencia de horario encontrada, salimos del loop
        IF v_hora_inicio_ok AND v_hora_termino_ok THEN
            EXIT;
        END IF;
    END LOOP;

    IF NOT (v_hora_inicio_ok AND v_hora_termino_ok) THEN
        RAISE_APPLICATION_ERROR(-20021,
            'Las horas reales no corresponden con el horario asignado (o están fuera de tolerancia).');
    END IF;

END trg_validar_asistencia;
/

--------------------------------------------------------------------------------
-- 3.3. Trigger: trg_validar_rango_sueldo
-- Valida que salary esté entre min_salary y max_salary de JOBS
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_validar_rango_sueldo
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    v_min_sal NUMBER;
    v_max_sal NUMBER;
BEGIN
    SELECT min_salary, max_salary
    INTO v_min_sal, v_max_sal
    FROM jobs
    WHERE job_id = :NEW.job_id;

    IF :NEW.salary IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'El salario no puede ser NULL.');
    ELSIF :NEW.salary < v_min_sal OR :NEW.salary > v_max_sal THEN
        RAISE_APPLICATION_ERROR(-20031,
            'Salario fuera del rango permitido para el puesto. Rango: ' ||
            TO_CHAR(v_min_sal) || ' - ' || TO_CHAR(v_max_sal));
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20032, 'Puesto (job_id) no encontrado en JOBS.');
END;
/

--------------------------------------------------------------------------------
-- Tabla de auditoría donde guardamos marcas cuando el registro está fuera de +/-30min
--------------------------------------------------------------------------------
CREATE TABLE inasistencias_log (
    log_id          NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    employee_id     NUMBER,
    fecha           DATE,
    hora_registro   TIMESTAMP,
    hora_esperada   VARCHAR2(50),
    diferencia_min  NUMBER,
    motivo          VARCHAR2(200),
    creado_en       DATE DEFAULT SYSDATE
);
/

--------------------------------------------------------------------------------
-- 3.4. Trigger: trg_marcar_inasistencia_fuera_ventana
-- BEFORE INSERT ON ASISTENCIA_EMPLEADO
-- Si la hora registrada está a +-30 minutos de la hora programada -> registra en inasistencias_log
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_marcar_inasistencia_fuera_ventana
BEFORE INSERT ON asistencia_empleado
FOR EACH ROW
DECLARE
    v_sched_start    DATE;
    v_diff_hours     NUMBER;
    v_reason         VARCHAR2(200);
BEGIN
    -- Intentamos obtener la hora programada para ese empleado en ese día
    -- Nota: ajusta las conversiones si tus columnas de HORARIO tienen tipos distintos.
    SELECT 
       -- concatenamos fecha de asistencia + hora_inicio programada y convertimos a DATE
       TO_DATE(TO_CHAR(:NEW.fecha_real,'YYYY-MM-DD') || ' ' || TO_CHAR(h.hora_inicio), 'YYYY-MM-DD HH24:MI:SS')
    INTO v_sched_start
    FROM empleado_horario eh
    JOIN horario h ON (eh.dia_de_la_semana = h.dia_de_la_semana AND eh.turno = h.turno)
    WHERE eh.employee_id = :NEW.employee_id
      AND (UPPER(h.dia_de_la_semana) = UPPER(TRIM(TO_CHAR(:NEW.fecha_real,'DAY','NLS_DATE_LANGUAGE=SPANISH')))
           OR h.dia_de_la_semana = TO_CHAR(:NEW.fecha_real,'D'))
    AND ROWNUM = 1; -- toma la primera coincidencia

    -- Convertir hora real a DATE para comparar
    DECLARE
        v_reg_start DATE;
    BEGIN
        v_reg_start := CAST(:NEW.hora_inicio_real AS DATE);

        -- Diferencia en minutos
        v_diff_hours := (v_reg_start - v_sched_start) * 24 * 60; -- minutos

        IF ABS(v_diff_hours) > 30 THEN
            -- insertar en tabla de auditoría (sin afectar el registro del empleado)
            v_reason := 'Registro fuera de ventana +/-30 min. Dif: ' || TO_CHAR(v_diff_hours) || ' min';
            INSERT INTO inasistencias_log(employee_id, fecha, hora_registro, hora_esperada, diferencia_min, motivo)
            VALUES(:NEW.employee_id, TRUNC(:NEW.fecha_real), SYSTIMESTAMP, TO_CHAR(v_sched_start,'HH24:MI:SS'), v_diff_hours, v_reason);
            -- No impedimos la inserción; solo registramos la inasistencia evaluada
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- si no hay horario programado, no hacemos nada
        WHEN OTHERS THEN
            NULL; -- para evitar bloquear el INSERT por errores de conversión
    END;

END trg_marcar_inasistencia_fuera_ventana;
/

