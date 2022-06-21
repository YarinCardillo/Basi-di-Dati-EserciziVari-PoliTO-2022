CREATE OR REPLACE TRIGGER aggiorna_sommario_catergoria
AFTER INSERT ON CALENDARIO_EVENTI
FOR EACH ROW 
DECLARE

        X char(20);
        Y number;
        Z number;

BEGIN

SELECT CategoriaEvento, CostoEvento into X, Y
FROM EVENTO 
WHERE CodE = :NEW.CodE

SELECT COUNT(*) into Z
FROM SOMMARIO_CATEGORIA
WHERE CategoriaEvento = :NEW.CategoriaEvento

IF (Z = 0)

INSERT INTO SOMMARIO_CATEGORIA
VALUES(X, :NEW.Data, 1, Y)

ELSE

UPDATE SOMMARIO_CATEGORIA
SET NumeroTotaleEventi = NumeroTotaleEventi, 
    CostoComplessivoEventi = CostoComplessivoEventi + Y
WHERE CategoriaEvento = X AND Data = :NEW.Data

END IF;
END

-------------------------------------------------

CREATE OR REPLACE TRIGGER integrita_costo_evento
BEFORE INSERT OR UPDATE OF CostoEvento, CategoriaEvento ON EVENTO
FOR EACH ROW
WHEN ((NEW.CategoriaEvento = 'Proiezione') AND (NEW.CostoEvento > 1500))
BEGIN

:NEW.CostoEvento := 1500;

END;

-------------------------------------------------

CREATE OR REPLACE TRIGGER max_numero_eventi
AFTER INSERT OR UPDATE OF Data ON CALENDARIO_EVENTI
DECLARE


BEGIN 

SELECT COUNT(*) INTO X
FROM CALENDARIO_EVENTI
WHERE Data IN (SELECT Data
               FROM CALENDARIO_EVENTI
               GROUP BY Data
               HAVING COUNT(*)>10);
IF (X <> 0) 
raise_application_error(XXX, "Troppi eventi in una sola data");
END IF;
END;