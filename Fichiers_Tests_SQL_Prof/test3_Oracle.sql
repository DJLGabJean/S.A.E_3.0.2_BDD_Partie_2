-- Test pour l'évaluation du projet 3 --
---------------------------------------------------
SET SERVEROUTPUT ON
prompt // Début du TEST pour l'évaluation du projet 3 : Gestion des Groupes//
prompt 
prompt Suppression des données existantes
DELETE FROM Reservation;
DELETE FROM Groupes;
DELETE FROM UE;
DELETE FROM Salle;
COMMIT;
prompt 
prompt // Procédure MajGroupe //
prompt Ajout de 4 Groupes (4 points)
EXECUTE MajGroupe('CM','BUT Info P',20);
EXECUTE MajGroupe('TD1','BUT Info 1',25);
EXECUTE MajGroupe('TD2','BUT Info 1',25);
EXECUTE MajGroupe('TD3','BUT Info 1',25);
prompt Modification du Groupe 'TD1' de 'BUT Info 1' (erreur : effectif<0)
EXECUTE MajGroupe('TD1','BUT Info 1',-1);
prompt Modification du Groupe 'TD3' de 'BUT Info 1' (effectif=20)
EXECUTE MajGroupe('TD3','BUT Info 1',20);
prompt Insertion des autres données pour le test
INSERT INTO Salle(NoSalle,Categorie,NbPlaces) VALUES('S1','Salle',30);
INSERT INTO UE(CodeUE,nomUE,Formation,HC,HTD,HTP) VALUES('BD1','Bases de Données 1','BUT Info 1',8,20,0);
INSERT INTO UE(CodeUE,nomUE,Formation,HC,HTD,HTP) VALUES('BD2','Bases de Données 2','BUT Info P',4,14,0)
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(1,'S1','BD1','TD3','BUT Info 1','TD',TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HTDRES=HTDRES+2 WHERE CodeUE='BD1';
COMMIT;
prompt Suppression du Groupe 'TD3' de 'BUT Info 1' et ses réservations
EXECUTE MajGroupe('TD3','BUT Info 1',0);
prompt 
prompt Insertion des autres données pour le test
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(2,'S1','BD1','TD1','BUT Info 1','TD',TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(3,'S1','BD1','TD2','BUT Info 1','TD',TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HTDRES=HTDRES+4 WHERE CodeUE='BD1'; -- 2h TD * 2 séances = 4h
COMMIT;
prompt
prompt // Procédure ReservationsGroupe //
prompt Liste des réservations du groupe 'TD1' de 'BUT Info 1' : 1 réservation
EXECUTE ReservationsGroupe('TD1','BUT Info 1') ;
prompt Liste des réservations de la formation 'BUT Info 1' : 2 réservations
EXECUTE ReservationsGroupe(null,'BUT Info 1') ;
prompt Liste des réservations du groupe 'CM' de 'BUT Info P' : pas de réservation
EXECUTE ReservationsGroupe('CM','BUT Info P') ;
prompt Liste des réservations du groupe 'TD3' de 'BUT Info 1' : pas de groupe ou de formation
EXECUTE ReservationsGroupe('TD3','BUT Info 1') ;
prompt 
prompt // Fonction EstLibre //
BEGIN
-- Le groupe 'TD1' de 'BUT Info 1' est-il libre le 12/12/22 à 10h30 pour 2h ? OUI
IF EstLibre('TD1', 'BUT Info 1', TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120) 
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
-- Le groupe 'TD2' de 'BUT Info 1' est-il libre le 12/12/22 à 10h30 pour 2h ? NON
IF EstLibre('TD2', 'BUT Info 1', TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120)  
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
-- Le groupe 'TD3' de 'BUT Info 1' est-il libre le 12/12/22 à 10h30 pour 2h ? : Groupe inexistant
IF EstLibre('TD3', 'BUT Info 1', TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120)  
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
END;