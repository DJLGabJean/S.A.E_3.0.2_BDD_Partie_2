
-- Insertion des données

INSERT INTO Salle(NoSalle, Categorie, NbPlaces) VALUES ('S1', 'Salle TP', 20),('A1', 'Amphi', 120),('S2', 'Salle', 40);
INSERT INTO ELP(CodeELP, NomELP, Formation, HC, HTD, HTP) VALUES ('BD1', 'Introduction aux Bases de Données', 'BUT Info 1', 8, 20, 0),('Algo1', 'Algorithmique 1', 'BUT Info 1', 25, 20, 0),('BD2', 'Bases de Données 2', 'BUT Info P', 4, 14, 0);
INSERT INTO Groupes(Groupe, Formation, Effectif) VALUES ('CM', 'BUT Info P', 20),('TD1', 'BUT Info 1', 25),('TD2', 'BUT Info 1', 25);
INSERT INTO Reservation(NoSalle, CodeELP, Groupe, Formation, Nature, Debut, Duree) 
VALUES ('S1','BD1', 'TD1','BUT Info 1','TD','2022-12-12 08:30','02:00'),
('S1','BD1','TD2','BUT Info 1','TD','2022-12-12 10:30','02:00'),
('A1','BD1','CM','BUT Info 1','Cours','2022-11-15 14:00','02:00'); 


-- CALL MajGroupe('CM', 'BUT Info P', 50); -- Test d'un groupe qui existe et qui change l'effectif dans la table Groupes
-- CALL MajGroupe('TD3','BUT Info 1', 25); -- Test d'un groupe qui existe pas et qui est ajouté dans la table Groupes
-- CALL MajGroupe('CM', 'BUT Info P', -2); -- Test d'un groupe qui existe et qui est supprimé de la table Groupes ainsi que ses réservations dans la table Reservation car son est Effectif est négatif 

-- CALL ReservationsGroupe();
-- SELECT EstLibre();


-- A utiliser avec les fonctions et procédures 

-- Salle  Exemple : ('S3','Salle',40);
-- ELP  Exemple : ('CPOOA','Conception et Programmation Objet','L3I',14,15,16);
-- Groupes  Exemple : ('TD3','BUT Info 1',25);
-- Reservationreservation  Exemple : ('S1','BD1','TD3','BUT Info 1','TD',TO_DATE('13/12/2022 1400','DD/MM/YYYY HH24MI'),120);
