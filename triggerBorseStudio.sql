CREATE OR REPLACE TRIGGER inserimento_graduatoria
AFTER INSERT ON DOMANDA_INSERIMENTO_GRADUATORIA
FOR EACH ROW
DECLARE


BEGIN

SELECT COUNT(*) INTO flag
FROM GRADUATORIA_STUDENTI
WHERE Matricola = :NEW.Matricola

IF(flag <> 0) THEN
raise_application_error(XXX, "Studente gia' presente in graduatoria");
END IF;

SELECT SUM(NumeroCrediti), AVG(Voto) INTO somma_crediti, media
FROM CORSO C, ESAMI_SOSTENUTI ES
WHERE C.CodCorso = ES.CodCorso
AND Matricola = :NEW.Matricola
AND Voto >= 18

IF(somma_crediti IS NULL or somma_crediti < 120) THEN
raise_application_error(XXX, "Numero crediti insufficiente");
END IF;

SELECT AnnoImmatricolazione INTO anno
FROM STUDENTE  
WHERE Matricola = :NEW.Matricola;

INSERT INTO GRADUATORIA_STUDENTI
VALUES(:NEW.Matricola, media*(SYSDATE-anno));

END;