
DROP TABLE IF EXISTS LesSportifs;
DROP TABLE IF EXISTS LesEquipes;
DROP TABLE IF EXISTS LesEpreuvesIndividuelles;
DROP TABLE IF EXISTS LesEpreuvesParEquipe;
DROP TABLE IF EXISTS LesMembresEquipes;
DROP TABLE IF EXISTS LesMedaillesIndividuelle;
DROP TABLE IF EXISTS LesMedaillesEquipe;
DROP TABLE IF EXISTS LesInscriptionsEpreuvesIndividuelles;
DROP TABLE IF EXISTS LesInscriptionsEpreuvesParEquipes;

CREATE TABLE LesSportifs(
idS        number(4),
nom        VARCHAR2(20),
prenom    VARCHAR2(20),
date_nais    DATE,
sexe VARCHAR2(7),
pays    VARCHAR2(20),
CONSTRAINT SP_PK PRIMARY KEY (idS),
CONSTRAINT SP_U1 UNIQUE (nom, prenom),
CONSTRAINT SP_CK1 CHECK (sexe IN ('homme','femme')),
CONSTRAINT SP_CK2 CHECK (idS > 999),
CONSTRAINT SP_CK3 CHECK (idS < 1501)
);

CREATE TABLE LesEquipes(
idEq    number(4),
CONSTRAINT EQ_PK PRIMARY KEY (idEq),
CONSTRAINT SP_CK2 CHECK (idEq > 0),
CONSTRAINT SP_CK2 CHECK (idEq < 101)
);


CREATE TABLE LesEpreuvesIndividuelles
(
idEp    number(3),
nom        VARCHAR2(25),
type    VARCHAR2(7),
dateEpi    DATE,
discipline    VARCHAR2(25),
CONSTRAINT EPI_PK PRIMARY KEY (idEp),
CONSTRAINT EPI_CK CHECK (type IN ('homme', 'femme', 'mixte'))
);

CREATE TABLE LesEpreuvesParEquipe
(
idEp   NUMBER(4),
nom VARCHAR2(20),
type VARCHAR2(7),
dateEpe    DATE,
minsp    NUMBER(2),
maxsp    NUMBER(2),
forme    VARCHAR2(8),
discipline    VARCHAR2(20),
CONSTRAINT EPE_PK PRIMARY KEY (idEp),
CONSTRAINT EPE_CK1 CHECK (type IN ('homme','femme','mixte')),
CONSTRAINT EPE_CK2 CHECK (forme IN ('Equipe', 'Couple')),
CONSTRAINT EPE_CK3 CHECK (minsp > 2),
CONSTRAINT EPE_CK4 CHECK (minsp <= maxsp)
);



CREATE TABLE LesMembresEquipes
(
idEq NUMBER(4),
idS NUMBER(4),
CONSTRAINT MEP_PK1 PRIMARY KEY (idEq, ids),
CONSTRAINT MEP_FK1 FOREIGN KEY (idEq) REFERENCES LesEquipes(idEq),
CONSTRAINT MEP_FK2 FOREIGN KEY (idS) REFERENCES LesSportifs(idS)
);

CREATE TABLE LesMedaillesIndividuelle
(
 idEp   NUMBER(4),
 gold     NUMBER(4),
 argent NUMBER(4),
 bronze NUMBER(4),
CONSTRAINT EP_PK1 PRIMARY KEY (idEp),
CONSTRAINT EP_CK1 CHECK (gold != argent),
CONSTRAINT EP_CK1 CHECK (bronze != argent),
CONSTRAINT EP_CK1 CHECK (gold != bronze),
CONSTRAINT MEP_FK2 FOREIGN KEY (gold) REFERENCES LesSportifs(idS),
CONSTRAINT MEP_FK2 FOREIGN KEY (argent) REFERENCES LesSportifs(idS),
CONSTRAINT MEP_FK2 FOREIGN KEY (bronze) REFERENCES LesSportifs(idS)
);

CREATE TABLE LesMedaillesEquipe
(
 idEp   NUMBER(4),
 gold     NUMBER(4),
 argent NUMBER(4),
 bronze NUMBER(4),
CONSTRAINT EP_PK1 PRIMARY KEY (idEp),
CONSTRAINT EP_CK1 CHECK (gold != argent),
CONSTRAINT EP_CK1 CHECK (bronze != argent),
CONSTRAINT EP_CK1 CHECK (gold != bronze),
CONSTRAINT MEP_FK2 FOREIGN KEY (gold) REFERENCES LesEquipes(idEq),
CONSTRAINT MEP_FK2 FOREIGN KEY (argent) REFERENCES LesEquipes(idEq),
CONSTRAINT MEP_FK2 FOREIGN KEY (bronze) REFERENCES LesEquipes(idEq)
);

CREATE TABLE LesInscriptionsEpreuvesIndividuelles
(
idEp NUMBER(4),
idS NUMBER(4),
CONSTRAINT IEI_PK1 PRIMARY KEY (idEp, ids),
CONSTRAINT IEI_FK1 FOREIGN KEY (idEp) REFERENCES LesEpreuvesIndividuelles(idEp),
CONSTRAINT IEI_FK2 FOREIGN KEY (idS) REFERENCES LesSportifs(idS)
);

CREATE TABLE LesInscriptionsEpreuvesParEquipes
(
idEq NUMBER(4),
idEp NUMBER(4),
CONSTRAINT IPE_PK1 PRIMARY KEY (idEq, idEp),
CONSTRAINT IPE_FK1 FOREIGN KEY (idEq) REFERENCES LesEquipes(idEq),
CONSTRAINT IPE_FK2 FOREIGN KEY (idEp) REFERENCES LesEpreuvesParEquipe(idEp)
);
