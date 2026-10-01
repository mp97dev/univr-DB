-- Schema: scuola
CREATE TABLE insegnante (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(50)  NOT NULL,
    cognome     VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) UNIQUE,
    materia     VARCHAR(50)  NOT NULL,
    data_assunzione DATE
);

CREATE TABLE classe (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(10) NOT NULL UNIQUE,   -- es. '3A'
    anno            INT NOT NULL CHECK (anno BETWEEN 1 AND 5),
    sezione         CHAR(1) NOT NULL,
    aula            VARCHAR(10),
    coordinatore_id INT REFERENCES insegnante(id)
);

CREATE TABLE studente (
    id           SERIAL PRIMARY KEY,
    nome         VARCHAR(50) NOT NULL,
    cognome      VARCHAR(50) NOT NULL,
    data_nascita DATE NOT NULL,
    email        VARCHAR(100) UNIQUE,
    citta        VARCHAR(50),
    classe_id    INT REFERENCES classe(id)       -- può essere NULL (studente non assegnato)
);

CREATE TABLE esame (
    id            SERIAL PRIMARY KEY,
    studente_id   INT NOT NULL REFERENCES studente(id),
    insegnante_id INT NOT NULL REFERENCES insegnante(id),
    materia       VARCHAR(50) NOT NULL,
    data          DATE NOT NULL,
    voto          NUMERIC(3,1) CHECK (voto BETWEEN 1 AND 10),  -- NULL = assente
    tipo          VARCHAR(10) NOT NULL CHECK (tipo IN ('scritto', 'orale'))
);
