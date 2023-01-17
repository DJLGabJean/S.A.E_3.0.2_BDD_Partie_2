-- BDD Script SAE 3.02 :

-- Suppression des tables et des constraintes associés

DROP TABLE IF EXISTS Salle CASCADE;
DROP TABLE IF EXISTS ELP CASCADE;
DROP TABLE IF EXISTS Groupes CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;

-- Suppression des procédures

-- DROP PROCEDURE IF EXISTS

-- Suppression des fonctions

-- DROP FUNCTION IF EXISTS

-- Création des tables

CREATE TABLE Salle (NoSalle INT PRIMARY KEY,
		    Categorie VARCHAR(10),
		    NbPlaces INT CHECK(NbPlaces>=0)
		    );

CREATE TABLE ELP (CodeELP INT PRIMARY KEY,
		  NomELP VARCHAR(40) NOT NULL,
		  Formation VARCHAR(15) NOT NULL,
		  HC INT CHECK(HC>=0),
		  HTD INT CHECK(HC>=0),
		  HTP INT CHECK(HTP>=0),
		  HCRes INT,
		  HTDRes INT,
		  HTPRes INT
		  );
ALTER TABLE ELP AUTO_INCREMENT = 0;

CREATE TABLE Groupes (Groupe VARCHAR(15) PRIMARY KEY,
		      Formation VARCHAR(15) NOT NULL REFERENCES ELP(Formation),
		      Effectif INT NOT NULL CHECK(Effectif>=0)
		      );

CREATE TABLE Reservation (NoReservation INT AUTO_INCREMENT PRIMARY KEY,
			  NoSalle INT REFERENCES Salle(NoSalle),
			  CodeELP INT REFERENCES ELP(CodeELP),
			  Groupe VARCHAR(15) REFERENCES Groupes(Groupe),
			  Formation VARCHAR(15) REFERENCES ELP(Formation),
			  Nature VARCHAR(15) NOT NULL,
			  Debut VARCHAR(20) NOT NULL,
			  Duree INT NOT NULL
			  );

-- Insertion des données

INSERT INTO Salle(NoSalle, Categorie, NbPlaces) VALUES (1, 'Amphi', 500),(2, 'Amphi', 350),(3, 'Salle', 50),(4, 'Salle', 50),(5, 'SalleTP', 35);
INSERT INTO ELP(CodeELP, NomELP, Formation, HC, HTD, HTP) VALUES (100, 'Développement Web', 'Informatique', 24, 18, 6),(101, 'Base de Données', 'Informatique', 24, 16, 8),(102, 'Algorithmes', 'Informatique', 24, 20, 4),(103, 'Mathématiques', 'Informatique', 24, 16, 8);
INSERT INTO Groupes(Groupe, Formation, Effectif) VALUES ('Promo', 'BUT Info 2', 25),('TD1', 'BUT Info 2', 12),('TD2', 'BUT Info 2', 13);

-- Validation des données

COMMIT;

-- Création des procédures/fonctions 
 
