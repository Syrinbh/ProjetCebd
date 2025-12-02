-- ====================================================================
-- TRIGGER: CheckInscriptionBeforeMedailleIndiv
-- OBJECTIF: Vérifier les contraintes avant l'insertion d'une médaille individuelle
-- CONTRAINTES VÉRIFIÉES:
--   1. Le sportif doit être inscrit à l'épreuve pour recevoir une médaille
--   2. Un sportif ne peut pas avoir deux médailles pour la même épreuve
-- DÉCLENCHEMENT: AVANT chaque INSERT dans LesMedaillesIndividuelles
-- ====================================================================
CREATE OR REPLACE TRIGGER CheckInscriptionBeforeMedailleIndiv
BEFORE INSERT ON LesMedaillesIndividuelles  -- Table cible: médailles individuelles
FOR EACH ROW                                -- Exécuté pour chaque ligne insérée
DECLARE
    -- Variables pour stocker les résultats des vérifications
    v_count_gold   NUMBER;   -- Nombre d'inscriptions trouvées pour le médaillé d'or
    v_count_argent NUMBER;   -- Nombre d'inscriptions trouvées pour le médaillé d'argent
    v_count_bronze NUMBER;   -- Nombre d'inscriptions trouvées pour le médaillé de bronze
BEGIN
    -- ============================================================
    -- VÉRIFICATION 1: Les sportifs doivent être inscrits à l'épreuve
    -- ============================================================
    
    -- Vérifier si le sportif médaillé d'or est inscrit à cette épreuve
    -- COUNT(*) retourne 1 si inscrit, 0 sinon
    SELECT COUNT(*) INTO v_count_gold
    FROM LesInscriptionsEpreuvesIndividuelles  -- Table des inscriptions
    WHERE idEp = :NEW.idEp                     -- Même épreuve que la médaille
      AND idS = :NEW.gold;                     -- Même sportif que le médaillé d'or

    -- Vérifier si le sportif médaillé d'argent est inscrit
    SELECT COUNT(*) INTO v_count_argent
    FROM LesInscriptionsEpreuvesIndividuelles
    WHERE idEp = :NEW.idEp
      AND idS = :NEW.argent;

    -- Vérifier si le sportif médaillé de bronze est inscrit
    SELECT COUNT(*) INTO v_count_bronze
    FROM LesInscriptionsEpreuvesIndividuelles
    WHERE idEp = :NEW.idEp
      AND idS = :NEW.bronze;

    -- Si un des trois sportifs n'est pas inscrit (count = 0), lever une exception
    -- Cette condition garantit que: Pour avoir une médaille, il faut être inscrit
    IF v_count_gold = 0 OR v_count_argent = 0 OR v_count_bronze = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Un ou plusieurs sportifs ne sont pas inscrits à cette épreuve individuelle');
    END IF;
    
    -- ============================================================
    -- VÉRIFICATION 2: Pas de doublon de médaille pour un même sportif
    -- ============================================================
    
    -- Vérifier qu'un sportif n'a pas deux médailles pour la même épreuve
    -- Cette condition compare les identifiants des sportifs entre eux
    -- Exemple: Si gold = argent, alors le même sportif aurait or ET argent
    IF (:NEW.gold = :NEW.argent) OR 
       (:NEW.gold = :NEW.bronze) OR 
       (:NEW.argent = :NEW.bronze) THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Un sportif ne peut pas avoir deux médailles pour la même épreuve');
    END IF;
    
    -- Si on arrive ici, toutes les vérifications sont passées
    -- L'insertion peut se poursuivre normalement
END;
/

-- ====================================================================
-- TRIGGER: CheckInscriptionBeforeMedailleEquipe
-- OBJECTIF: Vérifier les contraintes avant l'insertion d'une médaille par équipe
-- CONTRAINTES VÉRIFIÉES:
--   1. L'équipe doit être inscrite à l'épreuve pour recevoir une médaille
--   2. Une équipe ne peut pas avoir deux médailles pour la même épreuve
-- DÉCLENCHEMENT: AVANT chaque INSERT dans LesMedaillesEquipe
-- ====================================================================
CREATE OR REPLACE TRIGGER CheckInscriptionBeforeMedailleEquipe
BEFORE INSERT ON LesMedaillesEquipe          -- Table cible: médailles par équipe
FOR EACH ROW                                 -- Exécuté pour chaque ligne insérée
DECLARE
    -- Variables pour stocker les résultats des vérifications
    v_count_gold   NUMBER;   -- Nombre d'inscriptions trouvées pour l'équipe d'or
    v_count_argent NUMBER;   -- Nombre d'inscriptions trouvées pour l'équipe d'argent
    v_count_bronze NUMBER;   -- Nombre d'inscriptions trouvées pour l'équipe de bronze
BEGIN
    -- ============================================================
    -- VÉRIFICATION 1: Les équipes doivent être inscrites à l'épreuve
    -- ============================================================
    
    -- Vérifier si l'équipe médaillée d'or est inscrite à cette épreuve
    SELECT COUNT(*) INTO v_count_gold
    FROM LesInscriptionsEpreuvesParEquipes   -- Table des inscriptions par équipe
    WHERE idEp = :NEW.idEp                   -- Même épreuve que la médaille
      AND idEq = :NEW.gold;                  -- Même équipe que la médaille d'or

    -- Vérifier si l'équipe médaillée d'argent est inscrite
    SELECT COUNT(*) INTO v_count_argent
    FROM LesInscriptionsEpreuvesParEquipes
    WHERE idEp = :NEW.idEp
      AND idEq = :NEW.argent;

    -- Vérifier si l'équipe médaillée de bronze est inscrite
    SELECT COUNT(*) INTO v_count_bronze
    FROM LesInscriptionsEpreuvesParEquipes
    WHERE idEp = :NEW.idEp
      AND idEq = :NEW.bronze;

    -- Si une des trois équipes n'est pas inscrite (count = 0), lever une exception
    -- Cette condition garantit que: Pour avoir une médaille, il faut être inscrit
    IF v_count_gold = 0 OR v_count_argent = 0 OR v_count_bronze = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Une ou plusieurs équipes ne sont pas inscrites à cette épreuve par équipe');
    END IF;
    
    -- ============================================================
    -- VÉRIFICATION 2: Pas de doublon de médaille pour une même équipe
    -- ============================================================
    
    -- Vérifier qu'une équipe n'a pas deux médailles pour la même épreuve
    -- Cette condition compare les identifiants des équipes entre elles
    -- Exemple: Si gold = argent, alors la même équipe aurait or ET argent
    IF (:NEW.gold = :NEW.argent) OR 
       (:NEW.gold = :NEW.bronze) OR 
       (:NEW.argent = :NEW.bronze) THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Une équipe ne peut pas avoir deux médailles pour la même épreuve');
    END IF;
    
END;
/

-- ====================================================================
-- TRIGGER: VerifierMemePaysEquipe
-- OBJECTIF: Vérifier que tous les sportifs d'une même équipe sont du même pays
--           (contrainte explicitement mentionnée dans l'énoncé)
-- ÉNONCÉ: "Tous les sportifs d'une même équipe doivent être du même pays."
-- ====================================================================
CREATE OR REPLACE TRIGGER VerifierMemePaysEquipe
BEFORE INSERT OR UPDATE ON LesMembresEquipes
FOR EACH ROW
DECLARE
    v_pays_nouveau_membre VARCHAR2(20);
    v_pays_premier_membre VARCHAR2(20);
    v_nombre_membres NUMBER;
BEGIN
    -- 1. Récupérer le pays du nouveau sportif
    SELECT pays INTO v_pays_nouveau_membre
    FROM LesSportifs
    WHERE idS = :NEW.idS;
    
    -- 2. Vérifier s'il y a déjà des membres dans l'équipe
    SELECT COUNT(*) INTO v_nombre_membres
    FROM LesMembresEquipes
    WHERE idEq = :NEW.idEq;
    
    -- 3. Si ce n'est pas le premier membre de l'équipe
    IF v_nombre_membres > 0 THEN
        -- Récupérer le pays du premier membre de l'équipe
        SELECT DISTINCT s.pays INTO v_pays_premier_membre
        FROM LesSportifs s
        JOIN LesMembresEquipes me ON s.idS = me.idS
        WHERE me.idEq = :NEW.idEq
        AND ROWNUM = 1;  -- Premier membre trouvé
        
        -- 4. Vérifier que le nouveau membre a le même pays
        IF v_pays_nouveau_membre != v_pays_premier_membre THEN
            RAISE_APPLICATION_ERROR(-20015,
                'Le sportif ' || :NEW.idS || ' (pays: ' || v_pays_nouveau_membre || 
                ') ne peut pas rejoindre l''équipe ' || :NEW.idEq || 
                ' car les membres actuels sont du pays: ' || v_pays_premier_membre ||
                '. Tous les membres d''une équipe doivent être du même pays.');
        END IF;
    END IF;
END;
/