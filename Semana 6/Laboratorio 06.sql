-- CREACIÓN DEL TABLESPACE 
    CREATE TABLESPACE bd02
     DATAFILE 
      'C:\app\andre\product\18.0.0\oradata\XE\bd02_01.dbf' SIZE 500M
      AUTOEXTEND ON NEXT 100M MAXSIZE 5G,
      'C:\app\andre\product\18.0.0\oradata\XE\bd02_02.dbf' SIZE 500M
      AUTOEXTEND ON NEXT 100M MAXSIZE 5G
     EXTENT MANAGEMENT LOCAL AUTOALLOCATE
     SEGMENT SPACE MANAGEMENT AUTO
     ONLINE;

-- CREACIÓN DEL TABLESPACE TEMPORAL
    CREATE TEMPORARY TABLESPACE tempbd02
     TEMPFILE 'C:\app\andre\product\18.0.0\oradata\XE\tempbd02_01.dbf'
     SIZE 200M
     EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
 
-- 1. CREACIÓN DE LAS TABLAS
-- EMPLEADOS
    CREATE TABLE empleados (
      dni            NUMBER(8),
      nombre         VARCHAR2(10)      NOT NULL,
      apellido1      VARCHAR2(15)      NOT NULL,
      apellido2      VARCHAR2(15),
      direcc1        VARCHAR2(25),
      direcc2        VARCHAR2(20),
      ciudad         VARCHAR2(20),
      provincia      VARCHAR2(20),
      cod_postal     VARCHAR2(5),
      sexo           VARCHAR2(1),
      fecha_nac      DATE
    ) TABLESPACE bd02;

-- DEPARTAMENTOS
    CREATE TABLE departamentos (
      dpto_cod       NUMBER(5),
      nombre_dpto    VARCHAR2(30)      NOT NULL,
      dpto_padre     NUMBER(5),
      presupuesto    NUMBER            NOT NULL,
      pres_actual    NUMBER
    ) TABLESPACE bd02;

-- ESTUDIOS
    CREATE TABLE estudios (
      empleado_dni   NUMBER(8),
      universidad    NUMBER(5),
      anio           NUMBER,
      grado          VARCHAR2(3),
      especialidad   VARCHAR2(20)
    ) TABLESPACE bd02;

-- UNIVERSIDADES
    CREATE TABLE universidades (
      univ_cod       NUMBER(5),
      nombre_univ    VARCHAR2(25)      NOT NULL,
      ciudad         VARCHAR2(20),
      municipio      VARCHAR2(2),
      cod_postal     VARCHAR2(5)
    ) TABLESPACE bd02;

-- HISTORIAL_LABORAL
    CREATE TABLE historial_laboral (
      empleado_dni   NUMBER(8),
      trabajo_cod    NUMBER(5),
      fecha_inicio   DATE,
      fecha_fin      DATE,
      dpto_cod       NUMBER(5),
      supervisor_dni NUMBER(8)
    ) TABLESPACE bd02;

-- HISTORIAL_SALARIAL
    CREATE TABLE historial_salarial (
      empleado_dni    NUMBER(8),
      salario         NUMBER           NOT NULL,
      fecha_comienzo  DATE,
      fecha_fin       DATE
    ) TABLESPACE bd02;

-- TRABAJOS
    CREATE TABLE trabajos (
      trabajo_cod    NUMBER(5),
      nombre_trab    VARCHAR2(20)      NOT NULL,
      salario_min    NUMBER(2)         NOT NULL,
      salario_max    NUMBER(2)         NOT NULL
    ) TABLESPACE bd02;

-- 2. El atributo SEXO en EMPLEADOS sólo puede tomar los valores H para hombre y M para mujer.
    ALTER TABLE empleados
      ADD CONSTRAINT ck_empleados_sexo
      CHECK (sexo IN ('H','M'));
  
-- 3. Dos DEPARTAMENTOS no se llaman igual. Dos TRABAJOS tampoco.
    ALTER TABLE departamentos
      ADD CONSTRAINT uq_departamentos_nombre
      UNIQUE (nombre_dpto);
    
    ALTER TABLE trabajos
      ADD CONSTRAINT uq_trabajos_nombre
      UNIQUE (nombre_trab);

-- 4. Cada empleado tiene un solo salario en cada momento. También, cada empleado tendrá asignado un solo trabajo en cada momento.
-- Un salario por empleado en cada instante.
    ALTER TABLE historial_salarial
      ADD CONSTRAINT ck_hsal_fechas
      CHECK (fecha_fin IS NULL OR fecha_fin > fecha_comienzo);
    
    CREATE UNIQUE INDEX ux_hsal_actual
    ON historial_salarial (
      CASE WHEN fecha_fin IS NULL THEN empleado_dni END
    );  
    
    ALTER TABLE historial_salarial
      MODIFY fecha_comienzo NOT NULL;
      
-- Un solo trabajo por empleado en cada instante.
    ALTER TABLE historial_laboral
      ADD CONSTRAINT ck_hlab_fechas
      CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio);
      
      CREATE UNIQUE INDEX ux_hlab_actual
    ON historial_laboral (
      CASE WHEN fecha_fin IS NULL THEN empleado_dni END
    );
    
    ALTER TABLE historial_laboral
      MODIFY fecha_inicio NOT NULL;

-- 5. Se ha de mantener la regla de integridad de referencia y pensar una clave primaria para cada tabla.
-- PKs
    ALTER TABLE empleados        ADD CONSTRAINT pk_empleados        PRIMARY KEY (dni);
    ALTER TABLE departamentos    ADD CONSTRAINT pk_departamentos    PRIMARY KEY (dpto_cod);
    ALTER TABLE trabajos         ADD CONSTRAINT pk_trabajos         PRIMARY KEY (trabajo_cod);
    ALTER TABLE universidades    ADD CONSTRAINT pk_universidades    PRIMARY KEY (univ_cod);
    ALTER TABLE historial_laboral
      ADD CONSTRAINT pk_historial_laboral PRIMARY KEY (empleado_dni, fecha_inicio);
    ALTER TABLE historial_salarial
      ADD CONSTRAINT pk_historial_salarial PRIMARY KEY (empleado_dni, fecha_comienzo);
    ALTER TABLE estudios
      ADD CONSTRAINT pk_estudios PRIMARY KEY (empleado_dni, universidad, anio);

-- FKs
    ALTER TABLE historial_laboral
      ADD CONSTRAINT fk_hlab_emp FOREIGN KEY (empleado_dni)
        REFERENCES empleados (dni);
    
    ALTER TABLE historial_laboral
      ADD CONSTRAINT fk_hlab_trab FOREIGN KEY (trabajo_cod)
        REFERENCES trabajos (trabajo_cod);
    
    ALTER TABLE historial_laboral
      ADD CONSTRAINT fk_hlab_dpto FOREIGN KEY (dpto_cod)
        REFERENCES departamentos (dpto_cod);
    
    ALTER TABLE historial_laboral
      ADD CONSTRAINT fk_hlab_supervisor FOREIGN KEY (supervisor_dni)
        REFERENCES empleados (dni);
    
    ALTER TABLE historial_salarial
      ADD CONSTRAINT fk_hsal_emp FOREIGN KEY (empleado_dni)
        REFERENCES empleados (dni);
    
    ALTER TABLE estudios
      ADD CONSTRAINT fk_estudios_emp FOREIGN KEY (empleado_dni)
        REFERENCES empleados (dni);
    
    ALTER TABLE estudios
      ADD CONSTRAINT fk_estudios_univ FOREIGN KEY (universidad)
        REFERENCES universidades (univ_cod);
    
-- 6. Agregue a la tabla empleados los campos de teléfono y celular para tener como ubicar rápidamente al empleado.
    ALTER TABLE empleados ADD telefono VARCHAR2(15);
    ALTER TABLE empleados ADD celular  VARCHAR2(15);

-- 7. Insertar datos
-- a) empleados
   INSERT INTO empleados (nombre, apellido1, apellido2, dni, sexo)
   VALUES ('Sergio', 'Palma',   'Entrena', 111222, 'H');
    
   INSERT INTO empleados (nombre, apellido1, apellido2, dni, sexo)
   VALUES ('Lucia',  'Ortega',  'Plus',    222333, 'M');

-- b) historia laboral
   INSERT INTO historial_laboral (empleado_dni, fecha_inicio, supervisor_dni)
   VALUES (111222, DATE '1996-06-16', 222333);

-- 8. ¿Qué ocurre si se modifica esta última fila de historial_laboral asignándole al empleado 111222 un supervisor que no existe en la tabla de empleados?
   UPDATE historial_laboral
   SET supervisor_dni = 999999
   WHERE empleado_dni = 111222
   AND fecha_inicio = DATE '1996-06-16';
-- Falla, porque el id padre no existe

/* 9. Borre una universidad de la tabla de UNIVERSIDADES ¿Qué le sucede a la 
   restricción de clave ajena de la tabla ESTUDIOS? Altere la definición de la tabla para
   que se mantenga la restricción, aunque se borre una universidad. */
   ALTER TABLE estudios DROP CONSTRAINT fk_estudios_univ;

   ALTER TABLE estudios
    ADD CONSTRAINT fk_estudios_univ
    FOREIGN KEY (universidad)
    REFERENCES universidades (univ_cod)
    ON DELETE CASCADE;

/* 10. Añada una restricción que obligue a que las personas que hayan introducido la
   CIUDAD deban tener el campo COD_POSTAL a NOT NULL. ¿Qué ocurre con las
   filas ya introducidas? */
   ALTER TABLE empleados
    ADD CONSTRAINT ck_emp_ciudad_cp
    CHECK (ciudad IS NULL OR cod_postal IS NOT NULL);
   
/* 11. Añada un nuevo atributo VALORACIÓN en la tabla de EMPLEADOS que indique
   de 1 a 10 la valoración que obtuvo el empleado en su entrevista de trabajo al
   iniciar su andadura en la empresa. Ponga el valor por defecto 5 para ese campo.*/
   ALTER TABLE empleados ADD valoracion NUMBER(2) DEFAULT 5 NOT NULL;

   ALTER TABLE empleados
    ADD CONSTRAINT ck_emp_valoracion
    CHECK (valoracion BETWEEN 1 AND 10);

/* 12. Elimine la restricción de que el atributo NOMBRE de la tabla EMPLEADOS no
   puede ser nulo.*/
   ALTER TABLE empleados MODIFY nombre NULL;

/* 13. Modificar el tipo de datos de DIREC1 de la tabla EMPLEADOS a cadena de 
   caracteres de 40 como máximo.*/
   ALTER TABLE empleados MODIFY direcc1 VARCHAR2(40);

/* 14. ¿Podría modificar el tipo de datos del atributo FECHA_NAC de la tabla 
   EMPLEADOS Y convertirla a tipo cadena? */
   ALTER TABLE empleados MODIFY fecha_nac VARCHAR2(10);

/* 15. Cambiar la clave primaria de EMPLEADOS al NOMBRE y los dos APELLIDOS. */
   ALTER TABLE empleados
    ADD CONSTRAINT uq_empleados_nombre_ap1_ap2
    UNIQUE (nombre, apellido1, apellido2);

/* 16. Crear una nueva tabla llamada INFORMACIÓN UNIVERSITARIA que tenga el
   NOMBRE y los dos APELLIDOS (en un solo atributo) de todos los EMPLEADOS
   junto con la UNIVERSIDAD donde estudiaron. Cárguela con los datos 
   correspondientes. */
   CREATE TABLE informacion_universitaria (
   empleado_y_apellidos VARCHAR2(60),
   universidad          VARCHAR2(25)
   );

   INSERT INTO informacion_universitaria (empleado_y_apellidos, universidad)
   SELECT
    RTRIM(
    nombre || ' ' || apellido1 || NVL(' ' || apellido2, ' ')
    ) AS empleado_y_apellidos,
    u.nombre_univ
   FROM empleados e
   JOIN estudios  es ON es.empleado_dni = e.dni
   JOIN universidades u ON u.univ_cod = es.universidad;

/* 17.Crear una vista llamada NOMBRE_EMPLEADOS con el NOMBRE y los dos 
   APELLIDOS (en un solo atributo) de todos los EMPLEADOS que son de Málaga. */
   CREATE OR REPLACE VIEW nombre_empleados AS
   SELECT
    RTRIM(
    nombre || ' ' || apellido1 || NVL(' ' || apellido2, ' ')
    ) AS nombre_completo
   FROM empleados
   WHERE ciudad = 'Málaga';

/* 18.Crear otra vista llamada INFORMACION_EMPLEADOS con el NOMBRE y los
   dos APELLIDOS (en un solo atributo) y EDAD (no fecha de nacimiento) de todos
   los EMPLEADOS. */
   CREATE OR REPLACE VIEW informacion_empleados AS
   SELECT
    RTRIM(
    nombre || ' ' || apellido1 || NVL(' ' || apellido2, ' ')
   ) AS nombre_completo,
   FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), fecha_nac) / 12) AS edad
   FROM empleados;

/* 19.Crear otra vista sobre la anterior llamada INFORMACION_ACTUAL que dispone
   de toda la información de INFORMACION_EMPLEADOS junto con el SALARIO
   que está cobrando en este momento. */
   CREATE OR REPLACE VIEW informacion_actual AS
   SELECT
    ie.nombre_completo,
    ie.edad,
    hs.salario AS salario_actual
   FROM informacion_empleados ie
   JOIN empleados e
    ON ie.nombre_completo = RTRIM(e.nombre || ' ' || e.apellido1 || NVL(' ' || e.apellido2, ' '))
   JOIN historial_salarial hs
    ON hs.empleado_dni = e.dni
    AND hs.fecha_comienzo <= TRUNC(SYSDATE)
    AND (hs.fecha_fin IS NULL OR TRUNC(SYSDATE) <= hs.fecha_fin);
   
/* 20.Borrar todas las tablas. ¿Hay que tener en cuenta las claves ajenas a la hora de
   borrar las tablas? */
   DROP VIEW informacion_actual;
   DROP VIEW informacion_empleados;
   DROP VIEW nombre_empleados;
    
   DROP TABLE informacion_universitaria;
    
   DROP TABLE estudios;
   DROP TABLE historial_laboral;
   DROP TABLE historial_salarial;
    
   DROP TABLE universidades;
   DROP TABLE trabajos;
   DROP TABLE departamentos;
   DROP TABLE empleados;
