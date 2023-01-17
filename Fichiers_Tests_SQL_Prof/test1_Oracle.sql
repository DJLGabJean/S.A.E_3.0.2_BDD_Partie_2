-- Test pour l'�valuation du projet 1 --
-------------------------------------------
SET SERVEROUTPUT ON
prompt // D�but du test pour l'�valuation du projet 1 : Gestion des Salles //
prompt 
prompt Suppression des donn�es existantes
DELETE FROM Reservation;
DELETE FROM Groupes;
DELETE FROM UE;
DELETE FROM Salle;
COMMIT;
prompt 
prompt // Proc�dure MajSalle //
prompt Ajout de 4 salles
EXECUTE MajSalle('S1','Salle TP',20);
EXECUTE MajSalle('A1','Amphi',120);
EXECUTE MajSalle('S2','Salle',40);
EXECUTE MajSalle('S3','Salle',40);
prompt Modification de la capacit� de la salle S3
EXECUTE MajSalle('S3','Salle',32);
prompt Cat�gorie de salle invalide
EXECUTE MajSalle('S4','SalleTD',40);
prompt NbPlaces < 0 (2 points)
EXECUTE MajSalle('A1','Amphi',-20);
prompt Insertion des autres donn�es pour le test
INSERT INTO UE(CodeUE,nomUE,Formation,HC,HTD,HTP) VALUES('BD1','Introduction aux Bases de Donn�es','BUT Info 1',8,20,0);
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('CM','BUT Info 1',70);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(1,'A1','BD1','CM','BUT Info 1','Cours',TO_DATE('10/12/2022 1030','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HCRES=HCRES+2 WHERE CodeUE='BD1';
COMMIT;
prompt Suppression de la salle A1 et ses r�servations
EXECUTE MajSalle('A1','Amphi',0);
prompt 
prompt Insertion des autres donn�es pour le test
INSERT INTO Groupes(Groupe,Formation,Effectif) VALUES('TD1','BUT Info 1',25);
INSERT INTO Reservation(NoReservation,NoSalle,CodeUE,Groupe,Formation,Nature,Debut,Duree) VALUES(2,'S1','BD1','TD1','BUT Info 1','TD',TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120);
UPDATE UE SET HTDRES=HTDRES+2 WHERE CodeUE='BD1';
COMMIT;
prompt 
prompt // Proc�dure SallesDisponibles //
prompt Les salles de capacit� >= 20 disponibles le 12/12/22 � 08h30 pour 2h : S1, S2,S3
EXECUTE SallesDisponibles(TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120,null,20) ;
prompt Les salles de 'TD' disponibles le 12/12/22 � 08h30 pour 2h : S2, S3
EXECUTE SallesDisponibles(TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120,'Salle',null) ;
prompt Les salles de 'TD' de capacit� >= 40 disponibles  le 12/12/22 � 08h30 pour 2h : S2
EXECUTE SallesDisponibles(TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120,'Salle',40) ;
prompt Les salles de 'Cat' disponibles  le 12/12/22 � 08h30 pour 2h : Cat�gorie inconnue
EXECUTE SallesDisponibles(TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120,'SalleTD',null) ;
prompt Salles de 'TP' de capacit� >= 20 disponibles le 12/12/22 � 10h30 pour 2h : aucune
EXECUTE SallesDisponibles(TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120,'Salle TP',20) ;
prompt 
prompt // Fonction EstDisponible //
BEGIN
-- Salle S1 disponible le 12/12/22 � 8h30 pour 2h ? OUI
IF EstDisponible('S1', TO_DATE('12/12/2022 0830','DD/MM/YYYY HH24MI'),120) 
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
-- Salle S1 disponible le 12/12/22 � 10h30 pour 2h ? NON
IF EstDisponible('S1', TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120) 
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
-- Salle A1 disponible le 12/12/22 � 10h30 pour 2h ? NON : Salle inexistante
IF EstDisponible('A1', TO_DATE('12/12/2022 1030','DD/MM/YYYY HH24MI'),120) 
THEN DBMS_OUTPUT.PUT_LINE('OUI');
ELSE DBMS_OUTPUT.PUT_LINE('NON');
END IF;
END;