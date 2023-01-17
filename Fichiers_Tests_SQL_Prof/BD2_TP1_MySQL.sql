-- BD2 - TP1
-- Suppression des objets
-- Suppression des tables et des contraintes associées
DROP TABLE IF EXISTS Services CASCADE;
DROP TABLE IF EXISTS UE CASCADE;
DROP TABLE IF EXISTS Enseignant CASCADE;
DROP TABLE IF EXISTS Grades CASCADE;
-- Suppression de la fonction EgaltD
DROP FUNCTION EgalTD;
-- Suppression des procédures
DROP PROCEDURE AjouterService;
DROP PROCEDURE SupprimerService;
DROP PROCEDURE ModifierService;

-- a) Création des tables
CREATE TABLE Grades ( 	grade VARCHAR(10) PRIMARY KEY, 
			serviceMin INT NOT NULL,
			serviceMax INT
			);
			 
CREATE TABLE Enseignant ( numEns INT AUTO_INCREMENT PRIMARY KEY, 
			nomEns VARCHAR(15) NOT NULL,
			grade VARCHAR(10) NOT NULL REFERENCES Grades(grade),
			service DECIMAL(5,2) DEFAULT 0
			);
ALTER TABLE Enseignant AUTO_INCREMENT=101;
			 
CREATE TABLE UE ( codeUE CHAR(8) PRIMARY KEY,
		nomUE VARCHAR(40) NOT NULL, 
		hC DECIMAL(4,2) CHECK(hC>=0),
		hTD DECIMAL(4,2) CHECK(hTD>=0),
		hTP DECIMAL(4,2) CHECK(hTP>=0)
		);

CREATE TABLE Services ( numEns INT REFERENCES Enseignant(numEns),
			codeUE CHAR(8) REFERENCES UE(codeUE),
			c DECIMAL(4,2) CHECK(c>=0),
			td DECIMAL(4,2) CHECK(td>=0),
			tp DECIMAL(4,2) CHECK(tp>=0),
			PRIMARY KEY(numEns, codeUE)
			 );

-- b) Insertion des données
-- Grades
INSERT INTO Grades(grade, serviceMin) VALUES ('Professeur',192),('MCF',192);
INSERT INTO Grades(grade, serviceMin, serviceMax) VALUES ('PRAG',384,null),('Moniteur',64,64),('Vacataire',0,200);
-- Enseignant
INSERT INTO Enseignant (nomEns, grade) VALUES ('LeProf','Professeur'),
('LeMaître','MCF'),('Durand','Moniteur'),('Dupond','PRAG');
-- UE
INSERT INTO UE(codeUE, nomUE, hC, hTD, hTP) VALUES ('UE1','Initiation au développement',10,20,10),
('UE2','Mathématiques',25,25,0),('UE3','Développement Orienté Objet',10,20,20),('UE4','Bases de Données 1',8,20,0);
-- Validation des insertions
COMMIT;

-- c) Création de la fonction EgalTD
DELIMITER //
CREATE FUNCTION EgalTD(ens INT, c DECIMAL(4,2), td DECIMAL(4,2), tp DECIMAL(4,2)) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
	DECLARE	gr VARCHAR(10);
	DECLARE s DECIMAL(5,2);
	DECLARE smin INT;
	DECLARE valeur DECIMAL(5,2);
	DECLARE vide INT;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vide=1;
	SET vide = 0;
	SELECT grade, service INTO gr, s FROM Enseignant WHERE numEns=ens;
	IF vide=1 THEN SET valeur = -1;
	ELSE
		SELECT serviceMin INTO smin FROM Grades WHERE grade=gr;
		IF s <= smin THEN
			SET valeur = COALESCE(c,0)*1.5 + COALESCE(td,0) + COALESCE(tp,0);
		ELSE
			SET valeur = COALESCE(c,0)*1.5 + COALESCE(td,0) + COALESCE(tp,0)*2/3;
		END IF;
	END IF;
	RETURN valeur;
END//
DELIMITER ;
-- test de la fonction
-- cas correct (37,5)
SELECT EgalTD(101, 25, 0, 0);
-- cas enseignant inexistant (-1)
SELECT EgalTD(100, 25, 0, 0);

-- d) + g) Création de la procédure AjouterService modifiée
ALTER TABLE Services ADD egaltd NUMBER(5,2);
DELIMITER //
CREATE PROCEDURE AjouterService(ens INT, codue CHAR(8), c DECIMAL(4,2), td DECIMAL(4,2), tp DECIMAL(4,2)) 
BEGIN
	DECLARE v_hc, v_htd, v_htp, v DECIMAL(4,2);
	DECLARE  depassement DECIMAL(5,2);
	DECLARE EXIT HANDLER FOR NOT FOUND SELECT 'UE inexistante' message;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
				BEGIN ROLLBACK; SELECT 'Erreur : opération annulée' message; END;
	DECLARE EXIT HANDLER FOR 1062 SELECT 'Clé dupliquée' message;
	IF COALESCE(c,0)+COALESCE(td,0)+COALESCE(tp,0)=0 THEN
		SELECT 'les heures saisies forment une combinaison de 0 et/ou de null' message;
  	ELSE
		SELECT hC, hTD, hTP INTO v_hc, v_htd, v_htp FROM UE WHERE codeUE=codue;
		IF (c>v_hc) OR (td>v_htd) OR (tp>v_htp) THEN
			SELECT 'les heures saisies sont supérieures aux heures de l''UE' message;
		ELSE 
			SET v = EgalTD(ens,c,td,tp);
			INSERT INTO Services (numEns,codeUE,c,td,tp,egaltd) VALUES (ens,codue,COALESCE(c,0),COALESCE(td,0),COALESCE(tp,0),v);
			UPDATE Enseignant SET service=service+v WHERE numEns=ens;
			SELECT COALESCE(service - serviceMax,0) INTO depassement 
			FROM Enseignant, Grades 
			WHERE Enseignant.grade=Grades.grade AND numEns=ens;
			IF depassement > 0 THEN
				SELECT 'le service dépasse le maximum attendu : insertion non validée' message;
				ROLLBACK;
			ELSE 
				SELECT CONCAT('le service de l''enseignant ',ens,' dans ',codue,' a été ajouté') message;
				COMMIT;
			END IF;
		END IF;
	END IF;
END;
//
DELIMITER ;
SET AUTOCOMMI=0;
-- Test de la procédure avec les différentes situations
-- Les heures de service supérieures aux heures de l'UE
call AjouterService(103,'UE2',25,30,15);
-- Les heures de service sont tous à 0
call AjouterService(103,'UE3',0,0,0);
-- Les heures de service sont tous null ou à 0
call AjouterService(103,'UE3',null,0,null);
-- Les heures de service sont tous null
call AjouterService(103,'UE3',null,null,null);
-- Pas de UE
call AjouterService(103,'UE10',25,20,0);
-- Pas d'enseignant
call AjouterService(100,'UE2',25,20,0);
-- Autre erreur Oracle (violation de CI : heures négatives)
call AjouterService(103,'UE4',8,6,-6);
-- Cas corrects
call AjouterService(101,'UE2',25,0,0);
call AjouterService(103,'UE3',10,20,20); 
-- Service en double
call AjouterService(103,'UE3',0,16,0); 
-- Dépassement de service
call AjouterService(103,'UE4',8,20,0);

-- e) + g) Création de la procédure SupprimerService modifiée
DELIMITER //
CREATE PROCEDURE SupprimerService(ens INT, codue VARCHAR(4))
BEGIN	
	DECLARE v DECIMAL(4,2);
	DECLARE EXIT HANDLER FOR NOT FOUND SELECT 'Service inexistant' message;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
				BEGIN ROLLBACK; SELECT 'Erreur : opération annulée' message; END;
  	SELECT egaltd INTO v FROM Services WHERE numEns=ens AND codeUE=codue;
	DELETE FROM Services WHERE numEns=ens AND codeUE=codue;
	UPDATE Enseignant SET service=service-v WHERE numEns=ens;
	COMMIT;
	SELECT CONCAT('le service de l''enseignant ',ens,' dans ',codue,' a été supprimé') message;
END;
//
DELIMITER ;
SET AUTOCOMMIT=0;
-- Test de la procédure
-- Cas service inexistant
call SupprimerService (103,'UE1');
-- Cas suppression
call SupprimerService(103, 'UE3');

-- f) Création de la procédure ModifierService
DELIMITER //
CREATE PROCEDURE ModifierService(ens INT, codue VARCHAR(4), c DECIMAL(4,2), td DECIMAL(4,2), tp DECIMAL(4,2))
BEGIN
	DECLARE n INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
				BEGIN ROLLBACK; SELECT 'Erreur : opération annulée' message; END;
-- Test d'existence de lignes dans une table (si nécessaire) : SupprimerService gère cette situation (NOT FOUND)
	SELECT COUNT(*) INTO n FROM Services WHERE numEns=ens AND codeUE=codue;
	IF n = 0 THEN SELECT 'Pas de service correspondant' message;
	ELSE
		IF  COALESCE(c,0)+COALESCE(td,0)+COALESCE(tp,0)=0 THEN
		-- suppression de service
			call SupprimerService(ens, codue);
		ELSE
		-- modification de service (supprimer+ajouter)
			call SupprimerService(ens, codue);
			call AjouterService(ens, codue, c, td, tp);
		END IF;
	END IF;
END;
//
DELIMITER ;
-- Test de la procédure
SET AUTOCOMMIT=0;
-- Cas service inexistant
call ModifierService(103,'UE1',10,10,10);
-- Cas modification
call AjouterService(103,'UE3',10,20,20); 
call ModifierService(103,'UE3',10,10,10);
-- Cas suppression
call ModifierService(103,'UE3',0,0,null);

-- g) Test de vérification du champ service
BEGIN
AjouterService(102,'UE1',10,20,10);
AjouterService(102,'UE2',25,25,0);
AjouterService(102,'UE3',10,20,20);
AjouterService(102,'UE4',8,20,0);
SupprimerService(102,'UE3');
SupprimerService(102,'UE1');
SupprimerService(102,'UE2');
SupprimerService(102,'UE4');
END ;
-- Résultat : le service est correct.

-- h) Programme d’affichage des enseignants 
-- avec boucle LOOP
DELIMITER //
CREATE PROCEDURE affichage()
BEGIN
	DECLARE	ServMin, Serv, Diff DECIMAL(5,2);
	DECLARE Num INT;
	DECLARE Nom VARCHAR(15);
	DECLARE vide INT DEFAULT 0;
	DECLARE liste CURSOR FOR 
		SELECT numEns, nomEns, service, serviceMin, service - serviceMin
		FROM Enseignant, Grades 
		WHERE Enseignant.grade=Grades.grade;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vide=1;
	OPEN liste;
Boucle :	LOOP
		FETCH liste INTO Num, Nom, Serv, ServMin, Diff ;
		IF vide=1 THEN LEAVE Boucle ; END IF;
		SELECT CONCAT(Num,' ',Nom,'  ',Serv,'  ',ServMin,'  ',Diff) 'Num Nom Service ServiceMIn Diff';
	END LOOP Boucle;
	CLOSE liste;
END;
//
DELIMITER ;
SET AUTOCOMMIT=0;
call affichage();
-- avec boucle REPEAT
DROP PROCEDURE IF EXISTS affichage;
DELIMITER //
CREATE PROCEDURE affichage()
BEGIN
	DECLARE	ServMin, Serv, Diff DECIMAL(5,2);
	DECLARE Num INT;
	DECLARE Nom VARCHAR(15);
	DECLARE vide INT DEFAULT 0;
	DECLARE liste CURSOR FOR 
		SELECT numEns, nomEns, service, serviceMin, service - serviceMin
		FROM Enseignant, Grades 
		WHERE Enseignant.grade=Grades.grade;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vide=1;
	OPEN liste;
	REPEAT
		FETCH liste INTO Num, Nom, Serv, ServMin, Diff ;
		IF vide=0 THEN SELECT CONCAT(RPAD(Num,12,' '),RPAD(Nom,12,' '),RPAD(Serv,12,' '),RPAD(ServMin,12,' '),Diff) 'Num Nom Service ServiceMIn Diff';
		END IF;
	UNTIL vide=1 END REPEAT;
	CLOSE liste;
END;
//
DELIMITER ;
SET AUTOCOMMIT=0;
call affichage();