-- 1. Obtenga el color y ciudad para las partes que no son de París, con un peso mayor
de diez.

CREATE OR REPLACE PROCEDURE SP_obtener_color_ciudad IS
 CURSOR partes_cur IS
  SELECT PNAME, 
         COLOR,
         CITY
  FROM P
  WHERE CITY <> 'London' AND WEIGHT>10; 
BEGIN
 FOR rec IN partes_cur LOOP
  dbms_output.put_line('Nombre: ' || rec.PNAME || ', ' || 'Color: ' || rec.COLOR || ', ' || 'Ciudad: ' || rec.CITY);
 END LOOP;
END;
/

SET SERVEROUTPUT ON;
EXEC SP_obtener_color_ciudad;

-- 2. Para todas las partes, obtenga el número de parte y el peso de dichas partes en
gramos.
CREATE OR REPLACE PROCEDURE SP_numero_peso IS
 CURSOR partes_cur IS
  SELECT P#,
         WEIGHT
  FROM P;
BEGIN
 FOR rec IN partes_CUR LOOP
  dbms_output.put_line('Número: ' || rec.P# || ', ' || 'PESO: ' || rec.WEIGHT);
 END LOOP;
END;
/

SET SERVEROUTPUT ON;
EXEC SP_numero_peso;

-- 3. Obtenga el detalle completo de todos los proveedores.
CREATE OR REPLACE PROCEDURE SP_obtener_detalle_proveedores 
IS
 CURSOR prov_cursor IS
  SELECT S#,
         SNAME,
         STATUS,
         CITY
  FROM S;
BEGIN
 FOR rec IN prov_cursor LOOP
  dbms_output.put_line('Número: ' || rec.S# || ', ' || 'Nombre: ' || rec.SNAME || ', '
                    || 'Estado: ' || rec.STATUS  || ', ' || 'Ciudad: ' || rec.CITY );
 END LOOP;
END;
/

SET SERVEROUTPUT ON;
EXEC SP_obtener_detalle_proveedores;

-- 4. Obtenga todas las combinaciones de proveedores y partes para aquellos proveedores y partes colocalizados.
CREATE OR REPLACE PROCEDURE SP_proveedores_partes_colocalizados IS
  CURSOR c_colocalizados IS
    SELECT s.S#, s.SNAME, p.P#, p.PNAME, s.CITY
    FROM S s
    JOIN P p ON s.CITY = p.CITY;
BEGIN
  FOR rec IN c_colocalizados LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Proveedor: ' || rec.SNAME || ' (' || rec.S# || ') ' ||
      '| Parte: ' || rec.PNAME || ' (' || rec.P# || ') ' ||
      '| Ciudad: ' || rec.CITY
    );
  END LOOP;
END SP_proveedores_partes_colocalizados;
/

SET SERVEROUTPUT ON;
EXEC SP_proveedores_partes_colocalizados;

-- 5. Obtenga todos los pares de nombres de ciudades de tal forma que el proveedor localizado en la primera ciudad del par abastece una parte almacenada en la segunda ciudad del par.
CREATE OR REPLACE PROCEDURE SP_pares_ciudades IS
  CURSOR c_ciudades IS
    SELECT DISTINCT
      s.CITY AS ciudad_proveedor,
      p.CITY AS ciudad_parte
    FROM S s
    JOIN SP sp ON sp.S# = s.S#
    JOIN P p  ON p.P# = sp.P#;
BEGIN
  FOR rec IN c_ciudades LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Proveedor en: ' || rec.ciudad_proveedor ||
      ' → Parte en: ' || rec.ciudad_parte
    );
  END LOOP;
END SP_pares_ciudades;
/

SET SERVEROUTPUT ON;
EXEC SP_pares_ciudades;

-- 6. Obtenga todos los pares de número de proveedor tales que los dos proveedores del par estén co-localizados.
CREATE OR REPLACE PROCEDURE SP_obtener_pares_proveedor_ciudad 
IS
 CURSOR pares_cur IS
  SELECT s1.S# AS proveedor_1,
         s2.S# AS proveedor_2,
         s1.CITY AS ciudad
  FROM S s1 JOIN S s2 ON s1.CITY = s2.CITY
  WHERE s1.S# < s2.S#;
BEGIN
 FOR rec IN pares_cur LOOP
  DBMS_OUTPUT.PUT_LINE(
      'Proveedores: ' || rec.proveedor_1 || ' y ' || rec.proveedor_2 || ', Ciudad: ' || rec.ciudad);
 END LOOP;
END;
/

SET SERVEROUTPUT ON;
EXEC SP_obtener_pares_proveedor_ciudad;

-- 7. Obtenga el número total de proveedores.
CREATE OR REPLACE FUNCTION FN_total_proveedores 
RETURN NUMBER
IS
 v_total NUMBER;
BEGIN
 SELECT COUNT(*) INTO v_total FROM S;
 RETURN v_total;
END;
/

SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Total de proveedores: ' || FN_total_proveedores);
END;
/


-- 8. Obtenga la cantidad mínima y la cantidad máxima para la parte P2.
CREATE OR REPLACE PROCEDURE SP_min_max_cant_por_parte(
 p_parte IN SP.P#%TYPE,
 p_min OUT SP.QTY%TYPE,
 p_max OUT SP.QTY%TYPE
)
IS
BEGIN
 SELECT MIN(QTY), MAX(QTY)
 INTO p_min, p_max
 FROM SP
 WHERE P# = p_parte;
END;
/

VARIABLE v_min NUMBER;
VARIABLE v_max NUMBER;

EXEC SP_min_max_cant_por_parte('P2', :v_min, :v_max);

PRINT v_min;
PRINT v_max;

-- 9. Para cada parte abastecida, obtenga el número de parte y el total despachado.
CREATE OR REPLACE PROCEDURE SP_total_por_parte IS
  CURSOR c_totales IS
    SELECT p.P#      AS parte,
           p.PNAME   AS nombre_parte,
           SUM(sp.QTY) AS total_despachado
    FROM P  p
    JOIN SP sp ON sp.P# = p.P#
    GROUP BY p.P#, p.PNAME
    ORDER BY p.P#;
BEGIN
  FOR r IN c_totales LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Parte: ' || r.parte ||
      ' | Nombre: ' || r.nombre_parte ||
      ' | Total despachado: ' || r.total_despachado
    );
  END LOOP;
END SP_total_por_parte;
/

SET SERVEROUTPUT ON;
EXEC SP_total_por_parte;

-- 10. Obtenga el número de parte para todas las partes abastecidas por más de un proveedor.
CREATE OR REPLACE PROCEDURE SP_partes_abastecidas_mayor_un_proveedor
IS
 CURSOR par_cursor IS
  SELECT P# AS parte
  FROM SP
  GROUP BY P#
  HAVING COUNT(DISTINCT S#) > 1
  ORDER BY P#;
BEGIN
  FOR r IN par_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Parte abastecida por >1 proveedor: ' || r.parte);
  END LOOP;
END;
/

SET SERVEROUTPUT ON;
EXEC SP_partes_abastecidas_mayor_un_proveedor;

-- 11. Obtenga el nombre de proveedor para todos los proveedores que abastecen la parte P2.
 CREATE OR REPLACE PROCEDURE SP_proveedor_por_parte(
p_prov IN P.P#%TYPE
) IS
 CURSOR prov_cursor IS
  SELECT DISTINCT s.SNAME AS name
  FROM S s
  JOIN SP sp ON s.S# = sp.S#
  WHERE sp.P# = p_prov;
BEGIN
  FOR r IN prov_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || r.name);
  END LOOP;
END;
/

SET SERVEROUTPUT ON;
EXEC SP_proveedor_por_parte('P2');


-- 12. Obtenga el nombre de proveedor de quienes abastecen por lo menos una parte.
CREATE OR REPLACE PROCEDURE SP_proveedores_con_abastecimiento IS
  CURSOR c_prov IS
    SELECT DISTINCT s.SNAME
    FROM S s
    JOIN SP sp ON sp.S# = s.S#;
BEGIN
  FOR r IN c_prov LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || r.SNAME);
  END LOOP;
END;
/

13. Obtenga el número de proveedor para los proveedores con estado menor que el máximo valor de estado en la tabla S.
CREATE OR REPLACE PROCEDURE SP_proveedores_estado_menor_max IS
  CURSOR c_prov IS
    SELECT SNAME, STATUS
    FROM S
    WHERE STATUS < (SELECT MAX(STATUS) FROM S);
BEGIN
  FOR r IN c_prov LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || r.SNAME || ' | Estado: ' || r.STATUS);
  END LOOP;
END;
/

-- 14. Obtenga el nombre de proveedor para los proveedores que abastecen la parte P2 (aplicar EXISTS en su solución).
CREATE OR REPLACE PROCEDURE SP_proveedores_P2_EXISTS IS
  CURSOR c_prov IS
    SELECT SNAME
    FROM S s
    WHERE EXISTS (
      SELECT 1 FROM SP sp
      WHERE sp.S# = s.S# AND sp.P# = 'P2'
    );
BEGIN
  FOR r IN c_prov LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || r.SNAME);
  END LOOP;
END;
/


-- 15. Obtenga el nombre de proveedor para los proveedores que no abastecen la parte P2.
CREATE OR REPLACE PROCEDURE SP_proveedores_no_P2 IS
  CURSOR c_prov IS
    SELECT SNAME
    FROM S s
    WHERE NOT EXISTS (
      SELECT 1 FROM SP sp
      WHERE sp.S# = s.S# AND sp.P# = 'P2'
    );
BEGIN
  FOR r IN c_prov LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || r.SNAME);
  END LOOP;
END;
/

-- 16. Obtenga el nombre de proveedor para los proveedores que abastecen todas las partes.
CREATE OR REPLACE PROCEDURE SP_proveedores_todas_partes IS
  CURSOR c_prov IS
    SELECT SNAME
    FROM S s
    WHERE NOT EXISTS (
      SELECT 1 FROM P p
      WHERE NOT EXISTS (
        SELECT 1 FROM SP sp
        WHERE sp.S# = s.S# AND sp.P# = p.P#
      )
    );
BEGIN
  FOR r IN c_prov LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || r.SNAME);
  END LOOP;
END;
/

-- 17. Obtenga el número de parte para todas las partes que pesan más de 16 libras ó son abastecidas por el proveedor S2, ó cumplen con ambos criterios.
CREATE OR REPLACE PROCEDURE SP_partes_peso_o_S2 IS
  CURSOR c_partes IS
    SELECT DISTINCT p.P#
    FROM P p
    LEFT JOIN SP sp ON sp.P# = p.P#
    WHERE p.WEIGHT > 16 OR sp.S# = 'S2';
BEGIN
  FOR r IN c_partes LOOP
    DBMS_OUTPUT.PUT_LINE('Parte: ' || r.P#);
  END LOOP;
END;
/


