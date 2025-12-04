-- ====================================================================
-- TRIGGER: CheckInscriptionBeforeMedailleIndiv
-- OBJECTIF: Verifier les contraintes avant l'insertion d'une medaille individuelle
-- CONTRAINTES VeRIFIeES:
--   1. Le sportif doit etre inscrit à l'epreuve pour recevoir une medaille
--   2. Un sportif ne peut pas avoir deux medailles pour la meme epreuve
-- DeCLENCHEMENT: AVANT chaque INSERT dans LesMedaillesIndividuelles
-- ====================================================================
CREATE OR REPLACE TRIGGER CheckInscriptionBeforeMedailleIndiv
BEFORE INSERT ON LesMedaillesIndividuelles  -- Table cible: medailles individuelles
FOR EACH ROW                                -- Execute pour chaque ligne inseree
DECLARE
    -- Variables pour stocker les resultats des verifications
    v_count_gold   NUMBER;   -- Nombre d'inscriptions trouvees pour le medaille d'or
    v_count_argent NUMBER;   -- Nombre d'inscriptions trouvees pour le medaille d'argent
    v_count_bronze NUMBER;   -- Nombre d'inscriptions trouvees pour le medaille de bronze
BEGIN
    -- ============================================================
    -- VeRIFICATION 1: Les sportifs doivent etre inscrits à l'epreuve
    -- ============================================================
    
    -- Verifier si le sportif medaille d'or est inscrit à cette epreuve
    -- COUNT(*) retourne 1 si inscrit, 0 sinon
    SELECT COUNT(*) INTO v_count_gold
    FROM LesInscriptionsEpreuvesIndividuelles  -- Table des inscriptions
    WHERE idEp = :NEW.idEp                     -- Meme epreuve que la medaille
      AND idS = :NEW.gold;                     -- Meme sportif que le medaille d'or

    -- Verifier si le sportif medaille d'argent est inscrit
    SELECT COUNT(*) INTO v_count_argent
    FROM LesInscriptionsEpreuvesIndividuelles
    WHERE idEp = :NEW.idEp
      AND idS = :NEW.argent;

    -- Verifier si le sportif medaille de bronze est inscrit
    SELECT COUNT(*) INTO v_count_bronze
    FROM LesInscriptionsEpreuvesIndividuelles
    WHERE idEp = :NEW.idEp
      AND idS = :NEW.bronze;

    -- Si un des trois sportifs n'est pas inscrit (count = 0), lever une exception
    -- Cette condition garantit que: Pour avoir une medaille, il faut etre inscrit
    IF v_count_gold = 0 OR v_count_argent = 0 OR v_count_bronze = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Un ou plusieurs sportifs ne sont pas inscrits à cette epreuve individuelle');
    END IF;
    
    -- ============================================================
    -- VeRIFICATION 2: Pas de doublon de medaille pour un meme sportif
    -- ============================================================
    
    -- Verifier qu'un sportif n'a pas deux medailles pour la meme epreuve
    -- Cette condition compare les identifiants des sportifs entre eux
    -- Exemple: Si gold = argent, alors le meme sportif aurait or ET argent
    IF (:NEW.gold = :NEW.argent) OR 
       (:NEW.gold = :NEW.bronze) OR 
       (:NEW.argent = :NEW.bronze) THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Un sportif ne peut pas avoir deux medailles pour la meme epreuve');
    END IF;
    
    -- Si on arrive ici, toutes les verifications sont passees
    -- L'insertion peut se poursuivre normalement
END;
/

-- ====================================================================
-- TRIGGER: CheckInscriptionBeforeMedailleEquipe
-- OBJECTIF: Verifier les contraintes avant l'insertion d'une medaille par equipe
-- CONTRAINTES VeRIFIeES:
--   1. L'equipe doit etre inscrite à l'epreuve pour recevoir une medaille
--   2. Une equipe ne peut pas avoir deux medailles pour la meme epreuve
-- DeCLENCHEMENT: AVANT chaque INSERT dans LesMedaillesEquipe
-- ====================================================================
CREATE OR REPLACE TRIGGER CheckInscriptionBeforeMedailleEquipe
BEFORE INSERT ON LesMedaillesEquipe          -- Table cible: medailles par equipe
FOR EACH ROW                                 -- Execute pour chaque ligne inseree
DECLARE
    -- Variables pour stocker les resultats des verifications
    v_count_gold   NUMBER;   -- Nombre d'inscriptions trouvees pour l'equipe d'or
    v_count_argent NUMBER;   -- Nombre d'inscriptions trouvees pour l'equipe d'argent
    v_count_bronze NUMBER;   -- Nombre d'inscriptions trouvees pour l'equipe de bronze
BEGIN
    -- ============================================================
    -- VeRIFICATION 1: Les equipes doivent etre inscrites à l'epreuve
    -- ============================================================
    
    -- Verifier si l'equipe medaillee d'or est inscrite à cette epreuve
    SELECT COUNT(*) INTO v_count_gold
    FROM LesInscriptionsEpreuvesParEquipes   -- Table des inscriptions par equipe
    WHERE idEp = :NEW.idEp                   -- Meme epreuve que la medaille
      AND idEq = :NEW.gold;                  -- Meme equipe que la medaille d'or

    -- Verifier si l'equipe medaillee d'argent est inscrite
    SELECT COUNT(*) INTO v_count_argent
    FROM LesInscriptionsEpreuvesParEquipes
    WHERE idEp = :NEW.idEp
      AND idEq = :NEW.argent;

    -- Verifier si l'equipe medaillee de bronze est inscrite
    SELECT COUNT(*) INTO v_count_bronze
    FROM LesInscriptionsEpreuvesParEquipes
    WHERE idEp = :NEW.idEp
      AND idEq = :NEW.bronze;

    -- Si une des trois equipes n'est pas inscrite (count = 0), lever une exception
    -- Cette condition garantit que: Pour avoir une medaille, il faut etre inscrit
    IF v_count_gold = 0 OR v_count_argent = 0 OR v_count_bronze = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Une ou plusieurs equipes ne sont pas inscrites à cette epreuve par equipe');
    END IF;
    
    -- ============================================================
    -- VeRIFICATION 2: Pas de doublon de medaille pour une meme equipe
    -- ============================================================
    
    -- Verifier qu'une equipe n'a pas deux medailles pour la meme epreuve
    -- Cette condition compare les identifiants des equipes entre elles
    -- Exemple: Si gold = argent, alors la meme equipe aurait or ET argent
    IF (:NEW.gold = :NEW.argent) OR 
       (:NEW.gold = :NEW.bronze) OR 
       (:NEW.argent = :NEW.bronze) THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Une equipe ne peut pas avoir deux medailles pour la meme epreuve');
    END IF;
    
END;
/

-- ====================================================================
-- TRIGGER: VerifierMemePaysEquipe
-- OBJECTIF: Verifier que tous les sportifs d'une meme equipe sont du meme pays
--           (contrainte explicitement mentionnee dans l'enonce)
-- eNONCe: "Tous les sportifs d'une meme equipe doivent etre du meme pays."
-- ====================================================================
CREATE OR REPLACE TRIGGER VerifierMemePaysEquipe
BEFORE INSERT OR UPDATE ON LesMembresEquipes
FOR EACH ROW
DECLARE
    v_pays_nouveau_membre VARCHAR2(20);
    v_pays_premier_membre VARCHAR2(20);
    v_nombre_membres NUMBER;
BEGIN
    -- 1. Recuperer le pays du nouveau sportif
    SELECT pays INTO v_pays_nouveau_membre
    FROM LesSportifs
    WHERE idS = :NEW.idS;
    
    -- 2. Verifier s'il y a dejà des membres dans l'equipe
    SELECT COUNT(*) INTO v_nombre_membres
    FROM LesMembresEquipes
    WHERE idEq = :NEW.idEq;
    
    -- 3. Si ce n'est pas le premier membre de l'equipe
    IF v_nombre_membres > 0 THEN
        -- Recuperer le pays du premier membre de l'equipe
        SELECT DISTINCT s.pays INTO v_pays_premier_membre
        FROM LesSportifs s
        JOIN LesMembresEquipes me ON s.idS = me.idS
        WHERE me.idEq = :NEW.idEq
        AND ROWNUM = 1;  -- Premier membre trouve
        
        -- 4. Verifier que le nouveau membre a le meme pays
        IF v_pays_nouveau_membre != v_pays_premier_membre THEN
            RAISE_APPLICATION_ERROR(-20015,
                'Le sportif ' || :NEW.idS || ' (pays: ' || v_pays_nouveau_membre || 
                ') ne peut pas rejoindre l''equipe ' || :NEW.idEq || 
                ' car les membres actuels sont du pays: ' || v_pays_premier_membre ||
                '. Tous les membres d''une equipe doivent etre du meme pays.');
        END IF;
    END IF;
END;
/