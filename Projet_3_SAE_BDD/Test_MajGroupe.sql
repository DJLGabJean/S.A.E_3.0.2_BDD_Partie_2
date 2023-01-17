DROP PROCEDURE IF EXISTS MajGroupe;

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

-- CALL MajGroupe('TD3','BUT Info 1', 25); -- Test d'un groupe qui existe pas et qui est ajouté dans la table Groupes. Il existe quand on lance le programme
-- CALL MajGroupe('TD3','BUT Info 1', 0);
-- CALL MajGroupe('CM', 'BUT Info P', -2); -- Test d'un groupe qui existe et qui est supprimé de la table Groupes ainsi que ses réservations dans la table Reservation car son est Effectif est négatif 