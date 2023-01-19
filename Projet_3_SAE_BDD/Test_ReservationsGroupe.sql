DROP PROCEDURE IF EXISTS ReservationsGroupe;

DELIMITER //
CREATE PROCEDURE ReservationsGroupe (Gpe VARCHAR(10), Forma VARCHAR(10))
-- Recherche et affiche la liste chronologique des réservations d’un groupe d’une 
-- formation (Gpe, Forma) ou de tous les groupes d’une formation si Gpe est omis. 

-- La liste est présentée avec les informations suivantes : Début, Fin (Début+Durée), 
-- CodeUE, NomUE, Nature, NoSalle, Gpe ; 

-- Si le groupe ou la formation n’existe pas, on affiche un message d’erreur ; 

-- Si la liste est vide, on affiche le message « Pas de réservation pour ce groupe ou 
-- cette formation ».
BEGIN
	DECLARE Groupe_p INT;
	DECLARE Forma_p INT;
    DECLARE List_vide INT;

	IF Gpe IS NULL THEN
		SELECT r.Debut, r.Debut + INTERVAL r.Duree HOUR_SECOND AS Fin, r.CodeELP, e.NomELP, r.Nature, r.NoSalle, r.Groupe
		FROM Reservation r
		JOIN ELP e ON r.CodeELP = e.CodeELP
		WHERE r.Groupe = Gpe AND r.Formation = Forma
		GROUP BY r.NoReservation;
        
    ELSE
		SELECT COUNT(*) INTO Groupe_p FROM Groupes WHERE Groupe = Gpe;
        SELECT COUNT(*) INTO Forma_p FROM Groupes WHERE Formation = Forma;
		IF Groupe_p = 0 OR Forma_p = 0 THEN
			SET MESSAGE_TEXT = "Le groupe ou la formation n'existe pas";
            
		ELSE
			SELECT COUNT(*) INTO list_vide 
            FROM Reservation r
            JOIN ELP e ON r.CodeELP = e.CodeELP 
            WHERE r.Groupe = Gpe AND r.Formation = Forma;
            
            IF List_vide = 0 THEN
				SET MESSAGE_TEXT = "Pas de réservation pour ce groupe ou cette formation";
                
            ELSE
				SELECT r.Debut, r.Debut + INTERVAL r.Duree HOUR_SECOND AS Fin, r.CodeELP, e.NomELP, r.Nature, r.NoSalle, r.Groupe
				FROM Reservation r
				JOIN ELP e ON r.CodeELP = e.CodeELP
				WHERE r.Formation = Forma
				GROUP BY r.NoReservation;
            
            END IF;
		END IF;
    END IF;
END;
//
DELIMITER ;


--  Code produit par ChatGPT ------ 
-- DECLARE v_group_exists INT DEFAULT 0;
-- DECLARE v_form_exists INT DEFAULT 0;
-- Check if group exists
-- SELECT COUNT(*) INTO v_group_exists FROM Groupes WHERE Groupe = Gpe AND Formation = Forma;
-- IF v_group_exists = 0 THEN
	-- SET MESSAGE_TEXT = 'Error: Group or Formation does not exist';
-- END IF;

-- Check if formation exists
-- SELECT COUNT(*) INTO v_form_exists FROM ELP WHERE Formation = Forma;
-- IF v_form_exists = 0 THEN
    -- SET MESSAGE_TEXT = 'Error: Group or Formation does not exist';
-- END IF;

-- Get reservation details
-- SELECT Debut, DATE_ADD(Debut, INTERVAL Duree HOUR) as Fin, CodeELP, NomELP, Nature, NoSalle, Groupe
-- FROM Reservation JOIN ELP ON Reservation.CodeELP = ELP.CodeELP 
-- JOIN Groupes ON Reservation.Groupe = Groupes.Groupe WHERE 
-- (Gpe IS NULL OR Groupe = Gpe) AND (Forma IS NULL OR Formation = Forma)
-- ORDER BY Debut;

-- Check if no reservations
-- IF ROW_COUNT() = 0 THEN
    -- SELECT 'No reservations for this group or formation' AS 'Result';
-- END IF;