PRAGMA foreign_keys = on; 
CREATE TABLE LesSportifs(
idS        number(4),
nom        VARCHAR2(20),
prenom    VARCHAR2(20),
date_nais    DATE,
sexe VARCHAR2(7),
pays    VARCHAR2(20),
CONSTRAINT SP_PK PRIMARY KEY (idS),
CONSTRAINT SP_U1 UNIQUE (nom, prenom),
CONSTRAINT SP_CK1 CHECK (sexe IN ('masculin','feminin')),
CONSTRAINT SP_CK2 CHECK (idS > 999),
CONSTRAINT SP_CK3 CHECK (idS < 1501)
);

CREATE TABLE LesEquipes(
idEq    number(4),
/*type VARCHAR2(7),*/
CONSTRAINT EQ_PK PRIMARY KEY (idEq),
CONSTRAINT EQ_CK1 CHECK (idEq > 0),
CONSTRAINT EQ_CK2 CHECK (idEq < 101)
);


CREATE TABLE LesEpreuvesIndividuelles
(
idEp    number(4),
nom        VARCHAR2(25),
typeEpI    VARCHAR2(7),
dateEpi    DATE,
discipline    VARCHAR2(25),
CONSTRAINT EPI_PK PRIMARY KEY (idEp),
CONSTRAINT EPI_CK CHECK (typeEpI IN ('masculin', 'feminin', 'mixte'))
);

CREATE TABLE LesEpreuvesParEquipe
(
idEp   NUMBER(4),
nom VARCHAR2(20),
typeEpE VARCHAR2(7),
dateEpe    DATE,
forme    VARCHAR2(8),
discipline    VARCHAR2(20),
CONSTRAINT EPE_PK PRIMARY KEY (idEp),
CONSTRAINT EPE_CK1 CHECK (typeEpE IN ('masculin', 'feminin', 'mixte')),
CONSTRAINT EPE_CK2 CHECK (forme IN ('par equipe', 'par couple'))
);



CREATE TABLE LesMembresEquipes
(
idEq NUMBER(4),
idS NUMBER(4),
CONSTRAINT MEP_PK1 PRIMARY KEY (idEq, idS),
CONSTRAINT MEP_FK1 FOREIGN KEY (idEq) REFERENCES LesEquipes(idEq),
CONSTRAINT MEP_FK2 FOREIGN KEY (idS) REFERENCES LesSportifs(idS)
);

CREATE TABLE LesMedaillesIndividuelle
(
 idEp   NUMBER(4),
 gold     NUMBER(4),
 argent NUMBER(4),
 bronze NUMBER(4),
CONSTRAINT MEI_PK1 PRIMARY KEY (idEp),
CONSTRAINT MEI_FK0 FOREIGN KEY (idEp) REFERENCES LesEpreuvesIndividuelles(idEp),
CONSTRAINT MEI_CK1 CHECK (gold != argent),
CONSTRAINT MEI_CK2 CHECK (bronze != argent),
CONSTRAINT MEI_CK3 CHECK (gold != bronze),
CONSTRAINT MEI_FK1 FOREIGN KEY (gold) REFERENCES LesSportifs(idS),
CONSTRAINT MEI_FK2 FOREIGN KEY (argent) REFERENCES LesSportifs(idS),
CONSTRAINT MEI_FK3 FOREIGN KEY (bronze) REFERENCES LesSportifs(idS)
);

CREATE TABLE LesMedaillesEquipe
(
 idEp   NUMBER(4),
 gold     NUMBER(4),
 argent NUMBER(4),
 bronze NUMBER(4),
CONSTRAINT MEE_PK1 PRIMARY KEY (idEp),
CONSTRAINT MEE_FK0 FOREIGN KEY (idEp) REFERENCES LesEpreuvesParEquipe(idEp),
CONSTRAINT MEE_CK1 CHECK (gold != argent),
CONSTRAINT MEE_CK2 CHECK (bronze != argent),
CONSTRAINT MEE_CK3 CHECK (gold != bronze),
CONSTRAINT MEE_FK1 FOREIGN KEY (gold) REFERENCES LesEquipes(idEq),
CONSTRAINT MEE_FK2 FOREIGN KEY (argent) REFERENCES LesEquipes(idEq),
CONSTRAINT MEE_FK3 FOREIGN KEY (bronze) REFERENCES LesEquipes(idEq)
);

CREATE TABLE LesInscriptionsEpreuvesIndividuelles
(
idEp NUMBER(4),
idS NUMBER(4),
CONSTRAINT IEI_PK1 PRIMARY KEY (idEp, idS),
CONSTRAINT IEI_FK1 FOREIGN KEY (idEp) REFERENCES LesEpreuvesIndividuelles(idEp),
CONSTRAINT IEI_FK2 FOREIGN KEY (idS) REFERENCES LesSportifs(idS)
);

CREATE TABLE LesInscriptionsEpreuvesParEquipes
(
idEp NUMBER(4),
idEq NUMBER(4),
CONSTRAINT IPE_PK1 PRIMARY KEY (idEq, idEp),
CONSTRAINT IPE_FK1 FOREIGN KEY (idEq) REFERENCES LesEquipes(idEq),
CONSTRAINT IPE_FK2 FOREIGN KEY (idEp) REFERENCES LesEpreuvesParEquipe(idEp)
);
