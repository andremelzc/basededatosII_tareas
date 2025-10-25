--------------------------------------------------------
-- Archivo creado  - miércoles-setiembre-03-2025   
--------------------------------------------------------
REM INSERTING into ANDRE.CICLISTA
SET DEFINE OFF;
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (1,'Tadej Pogačar','Eslovenia',to_date('21/09/98','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (2,'Jonas Vingegaard','Dinamarca',to_date('10/12/96','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (3,'Egan Bernal','Colombia',to_date('13/01/97','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (4,'Primož Roglič','Eslovenia',to_date('29/10/89','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (5,'Remco Evenepoel','Bélgica',to_date('25/01/00','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (6,'Nairo Quintana','Colombia',to_date('04/02/90','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (7,'Richard Carapaz','Ecuador',to_date('29/05/93','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (8,'Enric Mas','España',to_date('07/01/95','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (9,'Geraint Thomas','Reino Unido',to_date('25/05/86','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (10,'Sepp Kuss','Estados Unidos',to_date('13/09/94','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (11,'Julian Alaphilippe','Francia',to_date('11/06/92','DD/MM/RR'));
Insert into ANDRE.CICLISTA (ID,NOMBRE,NACIONALIDAD,FECHA_NACIMIENTO) values (12,'Alejandro Valverde','España',to_date('25/04/80','DD/MM/RR'));
REM INSERTING into ANDRE.CONTRATO
SET DEFINE OFF;
Insert into ANDRE.CONTRATO (ID,ID_CICLISTA,ID_EQUIPO,FECHA_INICIO,FECHA_FIN) values (1,1,3,to_date('01/06/19','DD/MM/RR'),to_date('31/12/27','DD/MM/RR'));
Insert into ANDRE.CONTRATO (ID,ID_CICLISTA,ID_EQUIPO,FECHA_INICIO,FECHA_FIN) values (2,2,2,to_date('01/01/20','DD/MM/RR'),to_date('31/12/26','DD/MM/RR'));
Insert into ANDRE.CONTRATO (ID,ID_CICLISTA,ID_EQUIPO,FECHA_INICIO,FECHA_FIN) values (3,3,1,to_date('01/01/18','DD/MM/RR'),to_date('31/12/26','DD/MM/RR'));
Insert into ANDRE.CONTRATO (ID,ID_CICLISTA,ID_EQUIPO,FECHA_INICIO,FECHA_FIN) values (4,4,2,to_date('01/01/18','DD/MM/RR'),to_date('31/12/23','DD/MM/RR'));
Insert into ANDRE.CONTRATO (ID,ID_CICLISTA,ID_EQUIPO,FECHA_INICIO,FECHA_FIN) values (5,5,5,to_date('01/08/19','DD/MM/RR'),to_date('31/12/26','DD/MM/RR'));
Insert into ANDRE.CONTRATO (ID,ID_CICLISTA,ID_EQUIPO,FECHA_INICIO,FECHA_FIN) values (6,6,4,to_date('01/01/12','DD/MM/RR'),to_date('31/12/19','DD/MM/RR'));
REM INSERTING into ANDRE.EQUIPO
SET DEFINE OFF;
Insert into ANDRE.EQUIPO (ID,NOMBRE,NACIONALIDAD,NOMBRE_DIRECTOR) values (1,'INEOS Grenadiers','Reino Unido','Rod Ellingworth');
Insert into ANDRE.EQUIPO (ID,NOMBRE,NACIONALIDAD,NOMBRE_DIRECTOR) values (2,'Visma–Lease a Bike','Países Bajos','Merijn Zeeman');
Insert into ANDRE.EQUIPO (ID,NOMBRE,NACIONALIDAD,NOMBRE_DIRECTOR) values (3,'UAE Team Emirates','Emiratos Árabes Unidos','Mauro Gianetti');
Insert into ANDRE.EQUIPO (ID,NOMBRE,NACIONALIDAD,NOMBRE_DIRECTOR) values (4,'Movistar Team','España','Eusebio Unzué');
Insert into ANDRE.EQUIPO (ID,NOMBRE,NACIONALIDAD,NOMBRE_DIRECTOR) values (5,'Soudal Quick-Step','Bélgica','Patrick Lefevere');
REM INSERTING into ANDRE.PARTICIPACION
SET DEFINE OFF;
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (2,1,1);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (3,1,2);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (1,1,3);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (4,1,5);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (5,1,7);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (3,2,1);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (1,2,2);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (2,2,5);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (4,2,6);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (5,2,8);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (2,3,1);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (3,3,2);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (4,3,3);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (1,3,4);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (5,3,5);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (1,4,1);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (4,4,3);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (2,4,4);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (3,4,5);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (5,4,7);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (5,5,1);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (4,5,2);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (2,5,3);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (3,5,4);
Insert into ANDRE.PARTICIPACION (ID_EQUIPO,ID_PRUEBA,PUESTO_FINAL) values (1,5,5);
REM INSERTING into ANDRE.PRUEBA
SET DEFINE OFF;
Insert into ANDRE.PRUEBA (ID,NOMBRE,ANO_EDICION,NUM_ETAPAS,KM_TOTALES,GANADOR_ID) values (1,'Tour de France',2023,21,3405,2);
Insert into ANDRE.PRUEBA (ID,NOMBRE,ANO_EDICION,NUM_ETAPAS,KM_TOTALES,GANADOR_ID) values (2,'Giro d''Italia',2024,21,3325.6,1);
Insert into ANDRE.PRUEBA (ID,NOMBRE,ANO_EDICION,NUM_ETAPAS,KM_TOTALES,GANADOR_ID) values (3,'Vuelta a España',2023,21,3150.8,10);
Insert into ANDRE.PRUEBA (ID,NOMBRE,ANO_EDICION,NUM_ETAPAS,KM_TOTALES,GANADOR_ID) values (4,'Tour de France',2019,21,3365.8,3);
Insert into ANDRE.PRUEBA (ID,NOMBRE,ANO_EDICION,NUM_ETAPAS,KM_TOTALES,GANADOR_ID) values (5,'Vuelta a España',2022,21,3280,5);


--------------------------------------------------------------------------
-- CONSULTAS --
---------------------------------------------------------------------------
--------------------------------------------------------
-- CONSULTAS DE EJEMPLO - ESQUEMA ANDRE
--------------------------------------------------------

-- 1) Ganador de cada prueba
SELECT p.id,
       p.nombre       AS prueba,
       p.ano_edicion  AS anio,
       c.nombre       AS ciclista_ganador
FROM   prueba p
LEFT JOIN ciclista c ON c.id = p.ganador_id
ORDER BY p.ano_edicion DESC, p.nombre;

--------------------------------------------------------

-- 2) Tabla de posiciones del Tour de France 2023
SELECT p.nombre       AS prueba,
       p.ano_edicion  AS anio,
       e.nombre       AS equipo,
       pa.puesto_final
FROM   participacion pa
JOIN   prueba p ON p.id = pa.id_prueba
JOIN   equipo e ON e.id = pa.id_equipo
WHERE  p.nombre = 'Tour de France'
  AND  p.ano_edicion = 2023
ORDER BY pa.puesto_final;

--------------------------------------------------------

-- 3) Contratos activos el 31/12/2024
SELECT ci.nombre      AS ciclista,
       e.nombre       AS equipo,
       co.fecha_inicio,
       co.fecha_fin
FROM   contrato co
JOIN   ciclista ci ON ci.id = co.id_ciclista
JOIN   equipo e   ON e.id = co.id_equipo
WHERE  TO_DATE('31/12/2024','DD/MM/YYYY')
       BETWEEN co.fecha_inicio AND co.fecha_fin
ORDER BY co.fecha_fin;

--------------------------------------------------------

-- 4) Equipo actual de cada ciclista (a hoy)
SELECT ciclista,
       equipo,
       fecha_inicio,
       fecha_fin
FROM (
    SELECT ci.nombre   AS ciclista,
           e.nombre    AS equipo,
           co.fecha_inicio,
           co.fecha_fin,
           ROW_NUMBER() OVER (
               PARTITION BY ci.id
               ORDER BY co.fecha_fin DESC
           ) rn
    FROM   contrato co
    JOIN   ciclista ci ON ci.id = co.id_ciclista
    JOIN   equipo e   ON e.id = co.id_equipo
    WHERE  SYSDATE BETWEEN co.fecha_inicio AND co.fecha_fin
)
WHERE rn = 1
ORDER BY ciclista;

--------------------------------------------------------

-- 5) Victorias por equipo (puesto_final = 1)
SELECT e.nombre AS equipo,
       COUNT(*) AS victorias
FROM   participacion pa
JOIN   equipo e ON e.id = pa.id_equipo
WHERE  pa.puesto_final = 1
GROUP BY e.nombre
ORDER BY victorias DESC, equipo;

--------------------------------------------------------

-- 6) Pruebas en las que participó 'Movistar Team'
SELECT e.nombre       AS equipo,
       p.nombre       AS prueba,
       p.ano_edicion,
       pa.puesto_final
FROM   participacion pa
JOIN   equipo e ON e.id = pa.id_equipo
JOIN   prueba p ON p.id = pa.id_prueba
WHERE  e.nombre = 'Movistar Team'
ORDER BY p.ano_edicion DESC, p.nombre;


