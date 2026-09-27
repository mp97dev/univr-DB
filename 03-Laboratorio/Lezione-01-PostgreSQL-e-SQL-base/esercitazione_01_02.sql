-- 
-- Esercizio 2:
-- Inserire nell’entità Museo le seguenti tuple:
-- (Arena, Verona, piazza Bra, 045 8003204, martedì, 20), 
-- (CastelVecchio, Verona, Corso Castelvecchio, 045 594734, lunedì, 15);
--
INSERT INTO museo ( nome, città, indirizzo, numeroTelefono, giornoChiusura, prezzo ) VALUES
('Arena', 'Verona', 'piazza Bra', '045 8003204', 'MAR', 20),
('CastelVecchio', 'Verona', 'Corso Castelvecchio', '045 594734', 'LUN', 15);

-- 
-- Esercizio 3
-- Popolare le tabelle Opera e Mostra con almeno altre tre tuple ciascuna.
--
INSERT INTO opera ( nome, cognomeAutore, nomeAutore, museo, città, epoca, anno ) VALUES
( 'Vaso piccolo', 'Rossi', 'Mario', 'Arena', 'Verona', 'Romana', 300 ),
( 'Dipinto', 'Verdi', 'Paolo', 'Arena', 'Verona', NULL, NULL ),
( 'Vaso grande', 'Bianchi', 'Luigi', 'CastelVecchio', 'Verona', NULL, NULL );
--
INSERT INTO mostra( titolo, inizio, fine, museo, città, prezzo ) VALUES
( 'Mostra annuale', '2020-01-01', '2020-12-31', 'Arena', 'Verona', 20.00 ),
( 'Mostra estiva', '2021-06-01', '2021-09-30', 'Arena', 'Verona', 18.50 ),
( 'Mostra estiva', '2022-06-01', '2022-09-30', 'CastelVecchio', 'Verona', NULL );

--
-- Esercizio 4
-- Provare ad inserire nella relazione Museo tuple che violino i vincoli specificati.
--
INSERT INTO mostra( titolo, inizio, fine, museo, città, prezzo ) VALUES
( 'Mostra domenicale', '2022-03-20', '2022-03-20', 'Castelvecchio', 'Verona', NULL );
( 'Mostra domenicale', '2022-03-20', NULL, 'Castelvecchio', 'Verona', NULL );

--
-- Esercizio 5
-- Nell’entità Museo, aggiungere l’attributo sitoInternet e inserire gli opportuni valori.
--
ALTER TABLE museo ADD COLUMN sitoInternet VARCHAR(120);

--
-- Esercizio 6
-- Nell’entità Mostra modificare l’attributo prezzo in prezzoIntero ed aggiungere l’attributo prezzoRidotto con valore di default 5. 
-- Aggiungere il vincolo (di tabella o di attributo?) che garantisca che Mostra.prezzoRidotto sia minore di Mostra.prezzoIntero.
--
ALTER TABLE mostra RENAME COLUMN prezzo TO prezzoIntero;
ALTER TABLE mostra ADD COLUMN prezzoRidotto DECIMAL(6,2) DEFAULT 5;
ALTER TABLE mostra ADD CONSTRAINT checkPrezzo CHECK ( prezzoRidotto < prezzoIntero );

--
-- Esercizio 7
-- Nell’entità Museo aggiornare il prezzo aggiungendo 1 Euro alle tuple esistenti.
--
UPDATE museo SET prezzo = prezzo + 1;

--
-- Esercizio 8
-- Nell'entità Mostra aggiornare il prezzoRidotto aumentandolo di 1 Euro per quelle mostre che hanno prezzoIntero inferiore a 15 Euro.
--
UPDATE mostra
SET prezzoRidotto = prezzoRidotto + 1
WHERE prezzoIntero < 15;
