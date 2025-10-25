-- CREACIÓN DEL TABLESPACE 
CREATE TABLESPACE esquema
 DATAFILE 
  'C:\app\andre\product\18.0.0\oradata\XE\esquema01.dbf' SIZE 500M
  AUTOEXTEND ON NEXT 100M MAXSIZE 5G,
  'C:\app\andre\product\18.0.0\oradata\XE\esquema02.dbf' SIZE 500M
  AUTOEXTEND ON NEXT 100M MAXSIZE 5G
 EXTENT MANAGEMENT LOCAL AUTOALLOCATE
 SEGMENT SPACE MANAGEMENT AUTO
 ONLINE;

-- CREACIÓN DEL TABLESPACE TEMPORAL
CREATE TEMPORARY TABLESPACE tempEsquema
 TEMPFILE 'C:\app\andre\product\18.0.0\oradata\XE\tempesquema01.dbf'
 SIZE 200M
 EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
 
-- CREACIÓN DE LAS TABLAS JUNTO A SUS RESTRICCIONES
-- Personas (super tabla, a partir de esta saldrán los estudiants los profesores y los de administración)
CREATE TABLE persona (
  persona_id        NUMBER GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(120)  NOT NULL,
  direccion         VARCHAR2(200),
  telefono          VARCHAR2(20),
  email             VARCHAR2(150)  NOT NULL,
  CONSTRAINT pk_persona PRIMARY KEY (persona_id),
  CONSTRAINT uq_persona_email UNIQUE (email),
  -- chequeos simples (opcionales, ajusta a tu formato real)
  CONSTRAINT ck_persona_email CHECK (INSTR(email, '@') > 1),
  CONSTRAINT ck_persona_tel   CHECK (telefono IS NULL OR REGEXP_LIKE(telefono, '^[0-9 +()-]{6,}$'))
) TABLESPACE esquema;

-- Centros 
CREATE TABLE centro (
  centro_id         NUMBER GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(120) NOT NULL,
  direccion         VARCHAR2(200),
  CONSTRAINT pk_centro PRIMARY KEY (centro_id),
  CONSTRAINT uq_centro_nombre UNIQUE (nombre)
) TABLESPACE esquema;

-- Departamento (de profesores)
CREATE TABLE departamento (
  departamento_id   NUMBER GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(120) NOT NULL,
  CONSTRAINT pk_departamento PRIMARY KEY (departamento_id),
  CONSTRAINT uq_departamento_nombre UNIQUE (nombre)
) TABLESPACE esquema;

-- Titulaciones (como matrícula)
CREATE TABLE titulacion (
  titulacion_id     NUMBER GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(150) NOT NULL,
  CONSTRAINT pk_titulacion PRIMARY KEY (titulacion_id),
  CONSTRAINT uq_titulacion_nombre UNIQUE (nombre)
) TABLESPACE esquema;

-- Unidades administrativas (para personal no docente)
CREATE TABLE unidad_adm (
  unidad_id         NUMBER GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(120) NOT NULL,
  CONSTRAINT pk_unidad_adm PRIMARY KEY (unidad_id),
  CONSTRAINT uq_unidad_adm_nombre UNIQUE (nombre)
) TABLESPACE esquema;

-- Unidades administrativas (para personal no docente)
CREATE TABLE categoria_prof (
  categoria_id      NUMBER GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(120) NOT NULL,
  CONSTRAINT pk_categoria_prof PRIMARY KEY (categoria_id),
  CONSTRAINT uq_categoria_prof_nombre UNIQUE (nombre)
) TABLESPACE esquema;

-- Profesor (hereda de persona) + datos que se habían pedido
CREATE TABLE profesor (
  persona_id        NUMBER,
  departamento_id   NUMBER NOT NULL,
  dedicacion        VARCHAR2(10) NOT NULL,  
  CONSTRAINT pk_profesor PRIMARY KEY (persona_id),
  CONSTRAINT fk_profesor_persona
    FOREIGN KEY (persona_id) REFERENCES persona(persona_id),
  CONSTRAINT fk_profesor_departamento
    FOREIGN KEY (departamento_id) REFERENCES departamento(departamento_id),
  CONSTRAINT ck_profesor_dedicacion
    CHECK (dedicacion IN ('TC','TP')) 
) TABLESPACE esquema;

-- Relación N–N: profesores imparten en varios centros
CREATE TABLE profesor_centro (
  persona_id        NUMBER NOT NULL,
  centro_id         NUMBER NOT NULL,
  CONSTRAINT pk_profesor_centro PRIMARY KEY (persona_id, centro_id),
  CONSTRAINT fk_prof_centro_profesor
    FOREIGN KEY (persona_id) REFERENCES profesor(persona_id),
  CONSTRAINT fk_prof_centro_centro
    FOREIGN KEY (centro_id)  REFERENCES centro(centro_id)
) TABLESPACE esquema;

-- Alumnos (heredan de persona) + centro único de matrícula, expediente y titulación
CREATE TABLE alumno (
  persona_id        NUMBER,
  num_expediente    VARCHAR2(30) NOT NULL,
  titulacion_id     NUMBER NOT NULL,
  centro_id         NUMBER NOT NULL,
  CONSTRAINT pk_alumno PRIMARY KEY (persona_id),
  CONSTRAINT fk_alumno_persona
    FOREIGN KEY (persona_id) REFERENCES persona(persona_id),
  CONSTRAINT fk_alumno_titulacion
    FOREIGN KEY (titulacion_id) REFERENCES titulacion(titulacion_id),
  CONSTRAINT fk_alumno_centro
    FOREIGN KEY (centro_id) REFERENCES centro(centro_id),
  CONSTRAINT uq_alumno_expediente UNIQUE (num_expediente)
) TABLESPACE esquema;

-- Personal (administrativo/servicios): unidad administrativa y categoría profesional
CREATE TABLE personal (
  persona_id        NUMBER,
  unidad_id         NUMBER NOT NULL,
  categoria_id      NUMBER NOT NULL,
  CONSTRAINT pk_personal PRIMARY KEY (persona_id),
  CONSTRAINT fk_personal_persona
    FOREIGN KEY (persona_id) REFERENCES persona(persona_id),
  CONSTRAINT fk_personal_unidad
    FOREIGN KEY (unidad_id) REFERENCES unidad_adm(unidad_id),
  CONSTRAINT fk_personal_categoria
    FOREIGN KEY (categoria_id) REFERENCES categoria_prof(categoria_id)
) TABLESPACE esquema;

-- VISTA PARA LISTAR A TODOS LOS QUE TIENEN VÍNCULO CON LA UNIVERSIDAD CON DATOS COMUNES Y NO COMUNES
-- Creación de la vista
CREATE VIEW v_miembros_universidad AS
SELECT 
  p.persona_id,
  p.nombre,
  p.direccion,
  p.telefono,
  p.email,
  'PROFESOR'         AS tipo,
  d.nombre           AS departamento,
  pr.dedicacion      AS dedicacion,
  -- Centros donde imparte (pueden ser varios)
  (SELECT LISTAGG(c.nombre, ', ') WITHIN GROUP (ORDER BY c.nombre)
     FROM profesor_centro pc
     JOIN centro c ON c.centro_id = pc.centro_id
    WHERE pc.persona_id = pr.persona_id) AS centros_imparte,
  CAST(NULL AS VARCHAR2(30))  AS num_expediente,
  CAST(NULL AS VARCHAR2(150)) AS titulacion,
  CAST(NULL AS VARCHAR2(120)) AS unidad_adm,
  CAST(NULL AS VARCHAR2(120)) AS categoria_prof
FROM profesor pr
JOIN persona p       ON p.persona_id = pr.persona_id
JOIN departamento d  ON d.departamento_id = pr.departamento_id

UNION ALL

SELECT 
  p.persona_id,
  p.nombre,
  p.direccion,
  p.telefono,
  p.email,
  'ALUMNO'  AS tipo,
  CAST(NULL AS VARCHAR2(120)) AS departamento,
  CAST(NULL AS VARCHAR2(10))  AS dedicacion,
  CAST(NULL AS VARCHAR2(4000)) AS centros_imparte,
  a.num_expediente,
  t.nombre                 AS titulacion,
  CAST(NULL AS VARCHAR2(120)) AS unidad_adm,
  CAST(NULL AS VARCHAR2(120)) AS categoria_prof
FROM alumno a
JOIN persona p    ON p.persona_id = a.persona_id
JOIN titulacion t ON t.titulacion_id = a.titulacion_id

UNION ALL

SELECT 
  p.persona_id,
  p.nombre,
  p.direccion,
  p.telefono,
  p.email,
  'PERSONAL' AS tipo,
  CAST(NULL AS VARCHAR2(120)) AS departamento,
  CAST(NULL AS VARCHAR2(10))  AS dedicacion,
  CAST(NULL AS VARCHAR2(4000)) AS centros_imparte,
  CAST(NULL AS VARCHAR2(30))  AS num_expediente,
  CAST(NULL AS VARCHAR2(150)) AS titulacion,
  ua.nombre                  AS unidad_adm,
  cp.nombre                  AS categoria_prof
FROM personal s
JOIN persona p   ON p.persona_id = s.persona_id
JOIN unidad_adm ua ON ua.unidad_id = s.unidad_id
JOIN categoria_prof cp ON cp.categoria_id = s.categoria_id;

-- Consulta alfabética
SELECT *
FROM v_miembros_universidad
ORDER BY nombre;

-- CREACIÓN DE LOS ÍNDICES
-- Solo se crea un índice porque tanto como profesor, alumno y personal, heredan los datos que se piden de la tabla persona 
CREATE INDEX ix_persona_upper_nombre ON persona (UPPER(nombre));

-- INSERCIÓN DE DATOS
-- Centros
INSERT INTO centro (nombre, direccion)
VALUES ('Facultad de Ingeniería', 'Av. Universidad 123');

INSERT INTO centro (nombre, direccion)
VALUES ('Facultad de Ciencias', 'Av. Universidad 456');

-- Departamentos
INSERT INTO departamento (nombre)
VALUES ('Departamento de Matemáticas');

-- Titulaciones
INSERT INTO titulacion (nombre)
VALUES ('Grado en Ingeniería Informática');

-- Unidades administrativas
INSERT INTO unidad_adm (nombre)
VALUES ('Recursos Humanos');

-- Categorías profesionales
INSERT INTO categoria_prof (nombre)
VALUES ('Administrativo');

-- Profesor
INSERT INTO persona (nombre, direccion, telefono, email)
VALUES ('Ana López', 'Calle Sol 10', '600123123', 'ana.lopez@uni.edu');

-- Alumno
INSERT INTO persona (nombre, direccion, telefono, email)
VALUES ('Carlos Pérez', 'Av. Mar 25', '600456456', 'carlos.perez@uni.edu');

-- Personal
INSERT INTO persona (nombre, direccion, telefono, email)
VALUES ('María Gómez', 'Calle Luna 50', '600789789', 'maria.gomez@uni.edu');

-- Profesor: Ana López en Matemáticas, dedicación TC
INSERT INTO profesor (persona_id, departamento_id, dedicacion)
VALUES (1, 1, 'TC');

-- Relación profesor-centro (Ana imparte en Ingeniería y Ciencias)
INSERT INTO profesor_centro (persona_id, centro_id)
VALUES (1, 1);  -- Ingeniería

INSERT INTO profesor_centro (persona_id, centro_id)
VALUES (1, 2);  -- Ciencias

-- Alumno: Carlos Pérez, matrícula en Ingeniería Informática, centro Ingeniería
INSERT INTO alumno (persona_id, num_expediente, titulacion_id, centro_id)
VALUES (2, 'EXP2025-001', 1, 1);

-- Personal: María Gómez en RRHH con categoría Administrativo
INSERT INTO personal (persona_id, unidad_id, categoria_id)
VALUES (3, 1, 1);
