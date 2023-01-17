-- Test pour l'évaluation du projet --
-----------------------------------------
SET SERVEROUTPUT ON
prompt // Début du test pour l''évaluation du projet 4 : Gestion des Réservations //
prompt 
prompt Suppression des données existantes
DELETE FROM Reservation;
DELETE FROM Groupes;
DELETE FROM UE;
DELETE FROM Salle;
COMMIT;
prompt
prompt Insertion des données pour le test
INSERT INTO Salle(NoSalle,Categorie,NbPlaces) VALUES('S1','Salle TP',30);
INSERT INTO Salle(NoSalle,Categorie,NbPlaces) VALUES('S2','Salle',40);
INSERT INTO Salle(NoSalle,Categorie,NbPlaces) VALUES('A1','Amphi',120);
INSERT INTO UE(CodeUE,nomUE,Formation,HC,HTD,HTP) VALUES('BD1','Bases de Données 1','BUT Info 1',8,20,0);
INSERT INTO UE(CodeUE,nomUE,Formation,HC,HTD,HTP) VALUES('BD2','Bases de Données 2','BUT Info P',4,14,0)
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD1','BUT Info 1',25);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD2','BUT Info 1',25);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD3','BUT Info 1',20);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('CM','BUT Info 1',70);
COMMIT;
prompt 
prompt // Procédure Reserver //
prompt Ajout de 4 Réservations pour l'UE 'BD2', les heures réservées sont maj avec (2,0,6)
EXECUTE Reserver('S1','BD1', 'TD1','BUT Info 1','TD',TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120);
EXECUTE Reserver('S1','BD1','TD2','BUT Info 1','TD',TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120);
EXECUTE Reserver('A1','BD1','CM','BUT Info 1','Cours',TO_DATE('15/11/2022 1400','DD/MM/YYYY HH24MI'),120);
EXECUTE Reserver('S1','BD1','TD3','BUT Info 1','TD',TO_DATE('13/12/2022 1400','DD/MM/YYYY HH24MI'),120);
prompt effectif du groupe > capacité de la salle
EXECUTE Reserver('S1','BD1','CM','BUT Info 1','Cours',TO_DATE('12/11/2022 0830','DD/MM/YYYY HH24MI'),120);
prompt Groupe inexistant
EXECUTE Reserver('S1','BD2','TD1','BUT Info P','TD',TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120);
prompt Salle inexistante
EXECUTE Reserver('S3','BD1','TD1','BUT Info 1','TD',TO_DATE('16/11/2022 0830','DD/MM/YYYY HH24MI'),120);
prompt Durée nulle
EXECUTE Reserver('S1','BD1','TD2','BUT Info 1','TD',TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),0);
COMMIT;
prompt 
prompt // Procédure ReservationsSalle //
prompt Liste des réservations de la salle 'S1' : 3 réservations
EXECUTE ReservationsSalle('S1') ;
prompt Liste des réservations de la salle 'S2' : pas de réservation
EXECUTE ReservationsSalle('S2') ;
prompt Liste des réservations de la salle 'S3' : Salle inexistante
EXECUTE ReservationsSalle('S3') ;
prompt 
prompt // Fonction TauxOccupationSalle (Valide=4 points) //
prompt Taux occupation de la Salle 'S1' du '12/12/2022' au '13/12/2022' : 6/12=50%
SELECT TauxOccupationSalle('S1',TO_DATE('12/12/2022','DD/MM/YYYY'), TO_DATE('13/12/2022','DD/MM/YYYY')) Taux FROM Dual ;
prompt Taux occupation de la Salle 'S2' du '12/12/2022' au '13/12/2022' : 0%
SELECT TauxOccupationSalle('S2',TO_DATE('12/12/2022','DD/MM/YYYY'), TO_DATE('13/12/2022','DD/MM/YYYY')) Taux FROM Dual ;
prompt Taux occupation de la Salle 'S3' : Salle inexistante (4 points)
SELECT TauxOccupationSalle('S3',TO_DATE('12/12/2022','DD/MM/YYYY'), TO_DATE('13/12/2022','DD/MM/YYYY')) Taux FROM Dual ;