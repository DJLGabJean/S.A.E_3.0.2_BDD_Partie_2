DROP PROCEDURE IF EXISTS AfficherFinReservation;

DELIMITER //
CREATE PROCEDURE AfficherFinReservation (Gpe VARCHAR(10), Forma VARCHAR(20))
BEGIN
    SELECT r.Debut, r.Debut + INTERVAL r.Duree HOUR_SECOND AS Fin, r.CodeELP, e.NomELP, r.Nature, r.NoSalle, r.Groupe
    FROM Reservation r
    JOIN ELP e ON r.CodeELP = e.CodeELP
    WHERE r.Groupe = Gpe AND r.Formation = Forma
    GROUP BY r.NoReservation;
END;
//
DELIMITER ;


CALL AfficherFinReservation ('CM','BUT Info 1');

-- La liste est présentée avec les informations suivantes : Début, Fin (Début+Durée), 
-- CodeUE, NomUE, Nature, NoSalle, Gpe ; 