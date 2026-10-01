INSERT INTO turista (username, nome, cognome, data_nascita, email, citta) VALUES
('alice92',   'Alice',   'Bianchi',  '1995-04-12', 'alice.bianchi@mail.it',   'Torino'),
('brunom',    'Bruno',   'Marino',   '1988-11-02', 'bruno.marino@mail.it',    'Napoli'),
('carlav',    'Carla',   'Verdi',    '2000-02-20', 'carla.verdi@mail.it',     'Bologna'),
('davide87',  'Davide',  'Conti',    '1987-07-19', 'davide.conti@mail.it',    'Roma'),
('elenaf',    'Elena',   'Ferri',    '1993-09-05', 'elena.ferri@mail.it',     'Milano'),
('fabior',    'Fabio',   'Russo',    '1990-01-30', 'fabio.russo@mail.it',     'Palermo'),
('giuliat',   'Giulia',  'Testa',    '1998-06-14', 'giulia.testa@mail.it',    'Firenze'),
('hugob',     'Hugo',    'Becker',   '1985-03-08', NULL,                      'Berlino'),  -- turista straniero, senza email
('marcop',    'Marco',   'Pini',     '1992-05-22', 'marco.pini@mail.it',      'Venezia'),
('sarar',     'Sara',    'Rinaldi',  '1991-08-11', 'sara.rinaldi@mail.it',    'Genova'),
('tommasob',  'Tommaso', 'Bellini',  '1996-12-01', 'tommaso.bellini@mail.it', 'Torino');

INSERT INTO attrazione (codice, nome, citta, tipo, costo_biglietto) VALUES
('COL', 'Colosseo',               'Roma',     'monumento',         18.00),
('UFF', 'Galleria degli Uffizi',  'Firenze',  'museo',             25.00),
('DUO', 'Duomo di Milano',        'Milano',   'chiesa',            10.00),
('VAT', 'Musei Vaticani',         'Roma',     'museo',             20.00),
('POM', 'Scavi di Pompei',        'Napoli',   'sito archeologico', 16.00),
('TRE', 'Fontana di Trevi',       'Roma',     'monumento',          0.00);

-- Nota: "data" = giorno in cui è stata effettuata la prenotazione, "data_visita" = giorno
-- della visita vera e propria. Di norma coincidono (o sono vicini), ma in un paio di casi
-- sono stati inseriti di proposito a cavallo di due anni diversi (prenotazione a fine anno,
-- visita all'inizio dell'anno successivo), per esercitarsi a distinguere "prenotato nel"
-- da "visitato nel".
INSERT INTO prenotazione (turista, attrazione, data, data_visita, orario_visita) VALUES
-- Colosseo (COL)
('tommasob', 'COL', '2023-05-10', '2023-05-10', '10:00'),
('marcop',   'COL', '2024-04-01', '2024-04-01', '11:00'),
('sarar',    'COL', '2024-04-15', '2024-04-15', '09:30'),
('alice92',  'COL', '2025-03-10', '2025-03-10', '10:00'),
('brunom',   'COL', '2025-03-12', '2025-03-12', '10:30'),
('elenaf',   'COL', '2025-03-14', '2025-03-14', '11:00'),
('hugob',    'COL', '2025-03-16', '2025-03-16', '09:00'),
('giuliat',  'COL', '2025-12-29', '2026-01-02', '10:00'),  -- prenotata nel 2025, visita nel 2026
('alice92',  'COL', '2026-03-10', '2026-03-10', '10:00'),
('brunom',   'COL', '2026-03-12', '2026-03-12', '10:30'),
('elenaf',   'COL', '2026-03-14', '2026-03-14', '11:00'),
('hugob',    'COL', '2026-03-18', '2026-03-18', '09:00'),

-- Uffizi (UFF)
('marcop',    'UFF', '2023-06-01', '2023-06-01', '15:00'),
('sarar',     'UFF', '2023-06-05', '2023-06-05', '15:30'),
('marcop',    'UFF', '2024-06-01', '2024-06-01', '15:00'),
('sarar',     'UFF', '2024-06-05', '2024-06-05', '15:30'),
('tommasob',  'UFF', '2024-06-10', '2024-06-10', '16:00'),
('davide87',  'UFF', '2024-06-12', '2024-06-12', '14:00'),
('alice92',   'UFF', '2025-05-01', '2025-05-01', '15:00'),
('brunom',    'UFF', '2025-05-03', '2025-05-03', '15:30'),
('giuliat',   'UFF', '2025-05-05', '2025-05-05', '16:00'),
('alice92',   'UFF', '2026-05-01', '2026-05-01', '15:00'),
('giuliat',   'UFF', '2026-05-05', '2026-05-05', '16:00'),
('hugob',     'UFF', '2026-05-07', '2026-05-07', '16:30'),

-- Duomo di Milano (DUO)
('fabior',    'DUO', '2024-07-01', '2024-07-01', '09:00'),
('davide87',  'DUO', '2025-07-10', '2025-07-10', '09:30'),
('hugob',     'DUO', '2025-07-12', '2025-07-12', '10:00'),
('alice92',   'DUO', '2026-07-10', '2026-07-10', '09:30'),
('hugob',     'DUO', '2026-07-12', '2026-07-12', '10:00'),

-- Musei Vaticani (VAT)
('tommasob',  'VAT', '2023-08-01', '2023-08-01', '09:00'),
('marcop',    'VAT', '2024-08-01', '2024-08-01', '09:00'),
('sarar',     'VAT', '2024-08-03', '2024-08-03', '09:30'),
('tommasob',  'VAT', '2024-08-05', '2024-08-05', '10:00'),
('brunom',    'VAT', '2024-12-28', '2025-01-05', '09:00'),  -- prenotata nel 2024, visita nel 2025
('davide87',  'VAT', '2025-08-12', '2025-08-12', '10:00'),
('giuliat',   'VAT', '2025-08-14', '2025-08-14', '10:30'),
('giuliat',   'VAT', '2026-08-10', '2026-08-10', '10:00'),
('hugob',     'VAT', '2026-08-12', '2026-08-12', '10:30'),

-- Scavi di Pompei (POM) -- prima prenotazione in assoluto nel 2025
('giuliat',  'POM', '2025-09-10', '2025-09-10', '11:00'),
('marcop',   'POM', '2025-09-12', '2025-09-12', '11:30'),
('sarar',    'POM', '2025-09-14', '2025-09-14', '12:00'),
('carlav',   'POM', '2026-09-10', '2026-09-10', '11:00'),
('giuliat',  'POM', '2026-09-12', '2026-09-12', '11:30'),

-- Fontana di Trevi (TRE) -- nessuna prenotazione nel 2025
('marcop',  'TRE', '2024-10-01', '2024-10-01', '17:00'),
('sarar',   'TRE', '2024-10-03', '2024-10-03', '17:30'),
('carlav',  'TRE', '2026-10-05', '2026-10-05', '18:00');
