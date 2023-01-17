-- Suppression des tables et des constraintes associés

DROP TABLE IF EXISTS Salle CASCADE;
DROP TABLE IF EXISTS ELP CASCADE;
DROP TABLE IF EXISTS Groupes CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;

-- Suppression des procédures

DROP PROCEDURE IF EXISTS MajGroupe;
DROP PROCEDURE IF EXISTS ReservationsGroupe;

-- Suppression des fonctions

DROP FUNCTION IF EXISTS EstLibre;

-- Création des tables

CREATE TABLE Salle (NoSalle VARCHAR(3) PRIMARY KEY,
		    Categorie VARCHAR(10),
		    NbPlaces INT CHECK(NbPlaces>=0)
		    );

CREATE TABLE ELP (CodeELP VARCHAR(5) PRIMARY KEY,
		  NomELP VARCHAR(40) NOT NULL,
		  Formation VARCHAR(15) NOT NULL,
		  HC INT CHECK(HC>=0),
		  HTD INT CHECK(HC>=0),
		  HTP INT CHECK(HTP>=0),
		  HCRes INT,
		  HTDRes INT,
		  HTPRes INT
		  );

CREATE TABLE Groupes (Groupe VARCHAR(15) PRIMARY KEY,
		      Formation VARCHAR(15) NOT NULL REFERENCES ELP(Formation),
		      Effectif INT NOT NULL CHECK(Effectif>=0)
		      );

CREATE TABLE Reservation (NoReservation INT AUTO_INCREMENT PRIMARY KEY,
			  NoSalle VARCHAR(3) REFERENCES Salle(NoSalle),
			  CodeELP VARCHAR(5) REFERENCES ELP(CodeELP),
			  Groupe VARCHAR(15) REFERENCES Groupes(Groupe),
			  Formation VARCHAR(15) REFERENCES ELP(Formation),
			  Nature VARCHAR(15) NOT NULL,
			  Debut DATETIME,
			  Duree TIME
			  );


-- Validation des données

COMMIT;

-- Création des procédures/fonctions 

DELIMITER //
CREATE PROCEDURE MajGroupe (Gpe VARCHAR(10), Forma VARCHAR(10), Eff DECIMAL (4,2)) 
BEGIN
    IF Gpe AND FORMA AND EFF IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tous les paramètres sont requis';
    ELSE
        SELECT COUNT(*) INTO @count FROM Groupes WHERE Groupe = Gpe AND Formation = Forma;
        IF @count = 0 AND Eff > 0 THEN
            INSERT INTO Groupes(Groupe, Formation, Effectif) VALUES(Gpe, Forma, Eff);
        ELSEIF @count > 0 AND Eff > 0 THEN
            UPDATE Groupes SET Effectif = Eff WHERE Groupe = Gpe AND Formation = Forma;
        ELSE
            DELETE FROM Groupes WHERE Groupe = Gpe AND Formation = Forma;
            DELETE FROM Reservation WHERE Groupe = Gpe AND Formation = Forma;
        END IF;
    END IF;
END;
//
DELIMITER ;

CREATE PROCEDURE ReservationsGroupe (Gpe VARCHAR(10), Forma VARCHAR(10))
-- Recherche et affiche la liste chronologique des réservations d’un groupe d’une 
-- formation (Gpe, Forma) ou de tous les groupes d’une formation si Gpe est omis. 

-- La liste est présentée avec les informations suivantes : Début, Fin (Début+Durée), 
-- CodeUE, NomUE, Nature, NoSalle, Gpe ; 

-- Si le groupe ou la formation n’existe pas, on affiche un message d’erreur ; 

-- Si la liste est vide, on affiche le message « Pas de réservation pour ce groupe ou 
-- cette formation ».
BEGIN

END;
//

-- CREATE FUNCTION EstLibre (Gpe VARCHAR(10), Forma VARCHAR(10), Debut DATE, DUREE DECIMAL(4,2)) 
-- RETURNS BOOLEAN
-- DETERMINISTIC
-- BEGIN

-- END;
//
DELIMITER ;
