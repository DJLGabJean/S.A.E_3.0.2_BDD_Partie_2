DROP PROCEDURE IF EXISTS ReservationsGroupe;

DELIMITER //
CREATE PROCEDURE ReservationsGroupe (Gpe VARCHAR(10), Forma VARCHAR(10))
BEGIN
DECLARE v_group_exists INT DEFAULT 0;
DECLARE v_form_exists INT DEFAULT 0;
-- Check if group exists
SELECT COUNT(*) INTO v_group_exists FROM Groupes WHERE Groupe = Gpe AND Formation = Forma;
IF v_group_exists = 0 THEN
	SET MESSAGE_TEXT = 'Error: Group or Formation does not exist';
END IF;

-- Check if formation exists
SELECT COUNT(*) INTO v_form_exists FROM ELP WHERE Formation = Forma;
IF v_form_exists = 0 THEN
    SET MESSAGE_TEXT = 'Error: Group or Formation does not exist';
END IF;

-- Get reservation details
SELECT Debut, DATE_ADD(Debut, INTERVAL Duree HOUR) as Fin, CodeELP, NomELP, Nature, NoSalle, Groupe
FROM Reservation JOIN ELP ON Reservation.CodeELP = ELP.CodeELP 
JOIN Groupes ON Reservation.Groupe = Groupes.Groupe WHERE 
(Gpe IS NULL OR Groupe = Gpe) AND (Forma IS NULL OR Formation = Forma)
ORDER BY Debut;

-- Check if no reservations
IF ROW_COUNT() = 0 THEN
    SELECT 'No reservations for this group or formation' AS 'Result';
END IF;

END;
//
DELIMITER ;
