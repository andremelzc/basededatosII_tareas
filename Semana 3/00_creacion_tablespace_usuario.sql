--------------------------------------------------------
-- Archivo creado  - miércoles-setiembre-03-2025   
--------------------------------------------------------
--------------------------------------------------------
-- CREACIÓN DE TABLESPACES, USUARIO Y PRIVILEGIOS
--------------------------------------------------------

-- Tablespace de datos
CREATE TABLESPACE bd
  DATAFILE 'C:\app\andre\product\18.0.0\oradata\XE\database_01.dbf' 
  SIZE 100M
  AUTOEXTEND ON NEXT 10M MAXSIZE 1G;

-- Tablespace temporal
CREATE TEMPORARY TABLESPACE bd_temp
  TEMPFILE 'C:\app\andre\product\18.0.0\oradata\XE\database_temp01.dbf' 
  SIZE 50M
  AUTOEXTEND ON NEXT 5M MAXSIZE 500M;

--------------------------------------------------------
-- CREACIÓN DEL USUARIO ANDRE
--------------------------------------------------------
CREATE USER andre IDENTIFIED BY "190705"
  DEFAULT TABLESPACE bd
  TEMPORARY TABLESPACE bd_temp
  QUOTA UNLIMITED ON bd;

--------------------------------------------------------
-- ASIGNACIÓN DE PRIVILEGIOS BÁSICOS
--------------------------------------------------------
GRANT CREATE SESSION TO andre;
GRANT CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO andre;
