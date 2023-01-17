-- Test pour l'�valuation du projet 2 --
-------------------------------------------
SET SERVEROUTPUT ON
prompt // D�but du TEST pour l'�valuation du projet 2 : Gestion des Enseignements //
prompt 
prompt Suppression des donn�es existantes
DELETE FROM Reservation;
DELETE FROM Groupes;
DELETE FROM UE;
DELETE FROM Salle;
COMMIT;
prompt 
prompt // Proc�dure MajUE //
prompt Ajout de 4 UE (4 points)
EXECUTE MajUE('BD1',' Introduction aux Bases de Donn�es','BUT Info 1',8,20,0);
EXECUTE MajUE('Algo1','Algorithmique 1','BUT Info 1',25,20,0);
EXECUTE MajUE('BD2','Bases de Donn�es 2','BUT Info P',4,14,0);
EXECUTE MajUE('CPOOA','Conception et Programmation Objet','L3I',14,15,16);
prompt Modification des donn�es (NomUE, HC,HTD et HTP) de l'UE 'BD1'
EXECUTE MajUE('BD1','Bases de Donn�es 1','BUT Info 1',0,4,0);
prompt Heures de TP<0
EXECUTE MajUE('CPOOA','Conception et Programmation Objet','L3I',0,0,-10);
prompt Insertion des autres donn�es pour le test
INSERT INTO Salle(NoSalle,Categorie,NbPlaces) VALUES('S1','Salle',30);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('CM','BUT Info P',20);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(1,'S1','BD2','CM','BUT Info P','Cours',TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HCRES=HCRES+4 WHERE CodeUE='BD2';
COMMIT;
prompt Suppression de l'UE 'BD2' et ses r�servations
EXECUTE MajUE('BD2','BD2','BUT Info P',null,null,null);
prompt 
prompt Insertion des autres donn�es pour le test
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD1','BUT Info 1',25);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD2','BUT Info 1',25);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(2,'S1','BD1','TD1','BUT Info 1','TD',TO_DATE('12/12/2022 1330','DD/MM/YYYY HH24MI'),120);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(3,'S1','BD1','TD2','BUT Info 1','TP',TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HTDRES=HTDRES+4 WHERE CodeUE='BD1'; -- 2h TD * 2 s�ances = 4h
COMMIT;
prompt 
prompt // Proc�dure Reservations //
prompt Liste des r�servations de 'BD1' : 2 r�servations
EXECUTE Reservations('BD1') ;
prompt Liste des r�servations de 'Algo1' : pas de r�servation
EXECUTE Reservations('Algo1') ;
prompt Liste des r�servations de 'BD2' : UE inconnue
EXECUTE Reservations('BD2') ;
prompt 
prompt // Fonction ReservationComplete //
BEGIN
-- UE 'BD1' : OUI
IF ReservationComplete('BD1') 
THEN DBMS_OUTPUT.PUT_LINE('OUI'); -- 4h de TD r�serv�es / 4, donc r�servation compl�te
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
-- UE 'Algo1' : NON
IF ReservationComplete('Algo1') 
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
-- UE 'BD2' : UE inexistante
IF ReservationComplete('BD2') 
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
END;