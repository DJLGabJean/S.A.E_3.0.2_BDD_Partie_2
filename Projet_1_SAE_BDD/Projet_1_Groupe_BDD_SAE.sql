-- BDD Script SAE 3.02 :

-- Suppression des tables et des constraintes associés

DROP TABLE IF EXISTS `Salle` CASCADE;
DROP TABLE IF EXISTS `ELP` CASCADE;
DROP TABLE IF EXISTS `Groupes` CASCADE;
DROP TABLE IF EXISTS `Reservation` CASCADE;

-- Suppression des procédures

DROP PROCEDURE IF EXISTS `MajSalle`;
DROP PROCEDURE IF EXISTS `SallesDisponibles`;

-- Suppression des fonctions

DROP FUNCTION IF EXISTS `EstDisponible`;

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
INSERT INTO `Groupes` (Groupe, Formation, Effectif) VALUES ('Promo', 'BUT Info 2', 25),('TD1', 'BUT Info 2', 12),('TD2', 'BUT Info 2', 13),('TD3','BUT Info 2', 25);

-- Validation des données

COMMIT;

-- Création des procédures/fonctions 
DELIMITER //
CREATE PROCEDURE `MajSalle` (Salle VARCHAR(10), Cat VARCHAR(10), Nb INT)
BEGIN
	IF Salle IS NULL AND Nb > 0 THEN
		SELECT Salle, Nb FROM MajSalle, S.Salle WHERE Salle = S.NoSalle AND Nb = S.NbPlaces;
		INSERT INTO Salle VALUES (NoSalle, NbPlaces);
	END IF;

    IF Salle IS NOT NULL AND Nb > 0 THEN
		UPDATE Salle
		SET Nb = S.NbPlaces;
	END IF;

	IF Salle IS NOT NULL AND Nb = 0 THEN
		DELETE FROM Reservation
		WHERE Salle = NoSalle;
		DELETE FROM Salle
		WHERE NoSalle = Salle AND NbPlaces = Nb;
	END IF;
END //

CREATE FUNCTION `EstDisponible` (Salle VARCHAR(10), Debut DATE, Duree INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	IF Salle IS NULL THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : La Salle est indisponible ou inexistante dans la base de données';
	END IF;
	IF Salle IS NOT NULL AND Debut IS NULL AND Duree IS NULL THEN
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;
END //

CREATE PROCEDURE `SallesDisponibles` (Debut DATE, Duree INT, Cat VARCHAR(10), Nb INT)
BEGIN
	SELECT NoSalle, Categorie, NbPlaces FROM Salle WHERE NoSalle AND Categorie AND NbPlaces ORDER BY Categorie;
	IF Nb <= EstDisponible(Salle(NbPlaces)) THEN
		SELECT Categorie, NbPlaces
		FROM Salle
		WHERE Cat = Categorie IS NULL AND Nb = NbPlaces IS NULL;
	END IF;
    
	IF Cat IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : La catégorie est inexistante';
	END IF;
        
    IF Reservation IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Pas de salle disponible dans ce créneau horaire';
	END IF;
END //
DELIMITER ;
