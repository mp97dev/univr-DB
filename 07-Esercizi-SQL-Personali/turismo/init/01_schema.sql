-- Schema: turismo
CREATE TABLE turista (
    username     VARCHAR(30) PRIMARY KEY,
    nome         VARCHAR(50)  NOT NULL,
    cognome      VARCHAR(50)  NOT NULL,
    data_nascita DATE NOT NULL,
    email        VARCHAR(100) UNIQUE,
    citta        VARCHAR(50)
);

CREATE TABLE attrazione (
    codice          VARCHAR(10) PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    citta           VARCHAR(50)  NOT NULL,
    tipo            VARCHAR(30)  NOT NULL,   -- es. museo, monumento, parco, chiesa...
    costo_biglietto NUMERIC(6,2)
);

CREATE TABLE prenotazione (
    turista       VARCHAR(30) NOT NULL REFERENCES turista(username),
    attrazione    VARCHAR(10) NOT NULL REFERENCES attrazione(codice),
    data          DATE NOT NULL,              -- data in cui è stata effettuata la prenotazione
    data_visita   DATE NOT NULL,              -- data prevista della visita
    orario_visita TIME,
    PRIMARY KEY (turista, attrazione, data),
    CHECK (data_visita >= data)
);
