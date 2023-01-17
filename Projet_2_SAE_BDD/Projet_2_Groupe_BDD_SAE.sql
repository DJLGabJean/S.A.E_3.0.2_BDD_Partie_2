-- BDD Script SAE 3.02 :

-- Suppression des tables et des constraintes associés

DROP TABLE IF EXISTS `Salle` CASCADE;
DROP TABLE IF EXISTS `ELP` CASCADE;
DROP TABLE IF EXISTS `Groupes` CASCADE;
DROP TABLE IF EXISTS `Reservation` CASCADE;

-- Suppression des procédures

DROP PROCEDURE IF EXISTS `MajELP`;
DROP PROCEDURE IF EXISTS `Reservations`;

-- Suppression des fonctions

DROP FUNCTION IF EXISTS `ReservationComplete`;

-- Création des tables

CREATE TABLE `Salle` (
    NoSalle INT PRIMARY KEY,
    Categorie VARCHAR(10),
    NbPlaces INT CHECK (NbPlaces >= 0)
);

CREATE TABLE `ELP` (CodeELP INT PRIMARY KEY,
		  NomELP VARCHAR(40) NOT NULL,
		  Formation VARCHAR(15) NOT NULL,
		  HC INT CHECK(HC>=0),
		  HTD INT CHECK(HTD>=0),
		  HTP INT CHECK(HTP>=0),
		  HCRes INT,
		  HTDRes INT,
		  HTPRes INT
		  );
ALTER TABLE `ELP` AUTO_INCREMENT = 100;

CREATE TABLE `Groupes` (Groupe VARCHAR(15) PRIMARY KEY,
		      Formation VARCHAR(15) NOT NULL REFERENCES ELP(Formation),
		      Effectif INT NOT NULL CHECK(Effectif>=0)
		      );

CREATE TABLE `Reservation` (NoReservation INT AUTO_INCREMENT PRIMARY KEY,
			  NoSalle INT REFERENCES Salle(NoSalle),
			  CodeELP INT REFERENCES ELP(CodeELP),
			  Groupe VARCHAR(15) REFERENCES Groupes(Groupe),
			  Formation VARCHAR(15) REFERENCES ELP(Formation),
			  Nature VARCHAR(15) NOT NULL,
			  Debut VARCHAR(20) NOT NULL,
			  Duree INT NOT NULL
			  );

-- Insertion des données

INSERT INTO `Salle` (NoSalle, Categorie, NbPlaces) VALUES (1, 'Amphi', 500),(2, 'Amphi', 350),(3, 'Salle', 50),(4, 'Salle', 50),(5, 'SalleTP', 35);
INSERT INTO `ELP` (CodeELP, NomELP, Formation, HC, HTD, HTP) VALUES (100, 'Développement Web', 'Informatique', 24, 18, 6),(101, 'Base de Données', 'Informatique', 24, 16, 8),(102, 'Algorithmes', 'Informatique', 24, 20, 4),(103, 'Mathématiques', 'Informatique', 24, 16, 8);
INSERT INTO `Groupes` (Groupe, Formation, Effectif) VALUES ('Promo', 'BUT Info 2', 25),('TD1', 'BUT Info 2', 12),('TD2', 'BUT Info 2', 13),('TD3', 'BUT Info 2', 25);

-- Validation des données

COMMIT;

-- Création des procédures/fonctions 

DELIMITER //
CREATE PROCEDURE `MajELP` (Code VARCHAR(15), Nom VARCHAR(30), Forma VARCHAR(15), C INT, TD INT, TP INT)
BEGIN
    DECLARE test_enregistrement INT;
    SELECT COUNT(*) INTO test_enregistrement FROM ELP WHERE CodeELP = Code;
    IF test_enregistrement = 0 THEN
        INSERT INTO ELP (Code, Nom, Forma, C, TD, TP) VALUES (Code, Nom, Forma, C, TD, TP);
    ELSE
        UPDATE ELP SET NomELP = Nom, Formation = Forma, hC = C, hTD = TD, hTP = TP WHERE CodeELP = Code;
    END IF;
    IF C = 0 AND TD = 0 AND TP = 0 THEN
        DELETE FROM ELP WHERE CodeELP = Code;
        DELETE FROM Reservations WHERE ELP_id = (SELECT id FROM ELP WHERE CodeELP = Code);
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERREUR : l''ELP et toutes les réservations associées ont été supprimées';
    END IF;
END //

CREATE PROCEDURE `Reservations` (Code VARCHAR(15)) 
BEGIN
    DECLARE test_reservation INT;
    SELECT COUNT(*) INTO test_reservation FROM Reservation WHERE CodeELP = Code;
    IF test_reservation = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'l''ELP n''existe pas';
    ELSE
        SELECT Début, Début + Durée AS Fin, Groupe, Forma, Nature, NoSalle FROM reservations
        WHERE ELP_id = (SELECT id FROM nom_de_la_table WHERE Code = Code)
        ORDER BY Début;
        IF ROW_COUNT() = 0 THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERREUR : Pas de réservation pour cet ELP';
        END IF;
    END IF;
END //

CREATE FUNCTION `ReservationComplete`(Code VARCHAR(15))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_reservation INT;
    DECLARE heures_totales INT;
    DECLARE heures_reservees INT;
    SELECT COUNT(*) INTO v_reservation FROM Reservation WHERE CodeELP = Code;
    IF v_reservation = 0 THEN
        SELECT 'ERREUR : L''ELP n''existe pas' AS Error;
	END IF;
	IF v_reservation != 0 THEN
        SELECT (C + TD + TP) INTO heures_totales FROM Reservation WHERE CodeELP = Code;
        SELECT SUM(Durée) INTO heures_reservees FROM Reservations WHERE CodeELP IN (SELECT CodeELP FROM Reservation WHERE CodeELP = Code);
	END IF;
        IF heures_totales = heures_reservees THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
	END IF;
END //
DELIMITER ;


    
    

		
    
    