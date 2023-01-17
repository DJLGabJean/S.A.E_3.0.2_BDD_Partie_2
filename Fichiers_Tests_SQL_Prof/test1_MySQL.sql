-- Test pour l'évaluation du projet 1 --
-------------------------------------------
-- Création de la procédure pour le test
DELIMITER //
CREATE PROCEDURE test1()
BEGIN
-- Début du test pour l'évaluation du projet 1 : Gestion des Salles //
-- 
-- Suppression des données existantes
DELETE FROM Reservation;
DELETE FROM Groupes;
DELETE FROM UE;
DELETE FROM Salle;
COMMIT;
-- 
-- // Procédure MajSalle //
-- Ajout de 4 salles
CALL MajSalle('S1','Salle TP',20);
CALL MajSalle('A1','Amphi',120);
CALL MajSalle('S2','Salle',40);
CALL MajSalle('S3','Salle',40);
-- Modification de la capacité de la salle S3
CALL MajSalle('S3','Salle',32);
-- Catégorie de salle invalide
CALL MajSalle('S4','SalleTD',40);
-- NbPlaces < 0 (2 points)
CALL MajSalle('A1','Amphi',-20);
-- Insertion des autres données pour le test
INSERT INTO UE(CodeUE,nomUE,Formation,HC,HTD,HTP) VALUES('BD1','Introduction aux Bases de Données','BUT Info 1',8,20,0);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('CM','BUT Info 1',70);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(1,'A1','BD1','CM','BUT Info 1','Cours',TO_DATE('10/12/2022 1030','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HCRES=HCRES+2 WHERE CodeUE='BD1';
COMMIT;
-- Suppression de la salle A1 et ses réservations
CALL MajSalle('A1','Amphi',0);
-- 
-- Insertion des autres données pour le test
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD1','BUT Info 1',25);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(2,'S1','BD1','TD1','BUT Info 1','TD',TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HTDRES=HTDRES+2 WHERE CodeUE='BD1';
COMMIT;
-- 
-- // Procédure SallesDisponibles //
-- Les salles de capacité >= 20 disponibles le 12/12/22 à 08h30 pour 2h : S1, S2,S3
CALL SallesDisponibles(STR_TO_DATE('12/12/2022 0830','%d/%m%Y %H%i'),120,null,20) ;
-- Les salles de 'TD' disponibles le 12/12/22 à 08h30 pour 2h : S2, S3
CALL SallesDisponibles(STR_TO_DATE('12/12/2022 0830','%d/%m%Y %H%i'),120,'Salle',null) ;
-- Les salles de 'TD' de capacité >= 40 disponibles  le 12/12/22 à 08h30 pour 2h : S2
CALL SallesDisponibles(STR_TO_DATE('12/12/2022 1030','%d/%m%Y %H%i'),120,'Salle',40) ;
-- Les salles de 'Cat' disponibles  le 12/12/22 à 08h30 pour 2h : Catégorie inconnue
CALL SallesDisponibles(STR_TO_DATE('12/12/2022 1030','%d/%m%Y %H%i',120,'SalleTD',null) ;
-- Salles de 'TP' de capacité >= 20 disponibles le 12/12/22 à 10h30 pour 2h : aucune
CALL SallesDisponibles(STR_TO_DATE('12/12/2022 1030','%d/%m%Y %H%i'),120,'Salle TP',20) ;
-- 
-- // Fonction EstDisponible //
-- Salle S1 disponible le 12/12/22 à 8h30 pour 2h ? OUI
IF EstDisponible('S1', STR_TO_DATE('12/12/2022 0830','%d/%m%Y %H%i'),120) 
THEN SELECT 'OUI' Reponse;
ELSE SELECT 'NON' Reponse;
END IF;
-- Salle S1 disponible le 12/12/22 à 10h30 pour 2h ? NON
IF EstDisponible('S1', STR_TO_DATE('12/12/2022 1030','%d/%m%Y %H%i'),120) 
THEN SELECT 'OUI' Reponse;
ELSE SELECT 'NON' Reponse;
END IF;
-- Salle A1 disponible le 12/12/22 à 10h30 pour 2h ? NON : Salle inexistante
IF EstDisponible('A1', STR_TO_DATE('12/12/2022 1030','%d/%m%Y %H%i'),120) 
THEN SELECT 'OUI' Reponse;
ELSE SELECT 'NON' Reponse;
END IF;
END;
//
DELIMITER ;

-- Appel de la procédure
CALL test1();