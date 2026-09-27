--
-- Creazione dominio per i giorni della settimana
--
DROP DOMAIN IF EXISTS giorniSettimana CASCADE;
CREATE DOMAIN giorniSettimana AS CHAR (3) 
   CHECK(VALUE IN('LUN ', 'MAR ', 'MER ', 'GIO ', 'VEN ', 'SAB ', 'DOM '));

-- 
-- Tabella MUSEO
-- 
-- Vincoli:
-- Attributi diversi da NULL: Museo.giornoChiusura, Museo.prezzo
-- Valore di default: Museo.città = 'Verona', Museo.nome = 'MuseoVeronese', Museo.prezzo = 10
--
DROP TABLE if EXISTS museo CASCADE;
CREATE TABLE museo (
  nome VARCHAR(30) DEFAULT 'MuseoVeronese',
  città VARCHAR(20) DEFAULT 'Verona',
  indirizzo VARCHAR(80),
  numeroTelefono VARCHAR(12) CHECK( numeroTelefono SIMILAR TO '\+?[0 -9]+'),
  giornoChiusura giorniSettimana NOT NULL,
  prezzo DECIMAL(6,2) NOT NULL DEFAULT 10.00,
  PRIMARY KEY (nome , città)
);

-- 
-- Tabella MOSTRA
-- 
-- Vincoli:
-- Gli attributi museo e città sono chiavi esportate di Museo
-- Attributi diversi da NULL: Mostra.fine
--
DROP TABLE if EXISTS mostra;
CREATE TABLE mostra (
  titolo VARCHAR(30),
  inizio DATE,
  fine DATE NOT NULL,
  museo VARCHAR(30),
  città VARCHAR(20),
  prezzo DECIMAL(6,2),
  PRIMARY KEY (titolo, inizio),
  FOREIGN KEY (museo, città) REFERENCES museo
);

--
-- Tabella OPERA
-- 
-- Vincoli: 
-- Gli attributi museo e città sono chiavi esportate di Museo
--
DROP TABLE if EXISTS opera;
CREATE TABLE opera (
  nome VARCHAR(30),
  cognomeAutore VARCHAR(20),
  nomeAutore VARCHAR(20),
  museo VARCHAR(30),
  città VARCHAR(20),
  epoca VARCHAR(20),
  anno INTEGER,
  PRIMARY KEY (nome, cognomeAutore, nomeAutore),
  FOREIGN KEY (museo, città) REFERENCES museo
);

-- 
-- Tabella ORARIO
-- 
-- Vincoli:
-- Gli attributi museo e città sono chiavi esportate di Museo
-- Attributi diversi da NULL: Orario.museo, Orario.città, Orario.giorno
-- Valori di default: Orario.orarioApertura = '09:00 CET', Orario.orarioChiusura = '19:00 CET'
--
DROP TABLE if EXISTS orario;
CREATE TABLE orario (
  progressivo SERIAL PRIMARY KEY,
  museo VARCHAR(30) NOT NULL,
  città VARCHAR(20) NOT NULL,
  giorno giorniSettimana NOT NULL,
  orarioApertura TIME WITH TIME ZONE DEFAULT '09:00 CET',
  orarioChiusura TIME WITH TIME ZONE DEFAULT '19:00 CET',    
  FOREIGN KEY (museo, città) REFERENCES museo
);
