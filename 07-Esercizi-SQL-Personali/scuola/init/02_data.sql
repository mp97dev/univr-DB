INSERT INTO insegnante (nome, cognome, email, materia, data_assunzione) VALUES
('Maria',    'Rossi',    'm.rossi@scuola.it',    'Matematica', '2010-09-01'),
('Giuseppe', 'Bianchi',  'g.bianchi@scuola.it',  'Italiano',   '2005-09-01'),
('Laura',    'Verdi',    'l.verdi@scuola.it',    'Inglese',    '2015-09-01'),
('Paolo',    'Neri',     'p.neri@scuola.it',     'Storia',     '2018-09-01'),
('Anna',     'Gallo',    'a.gallo@scuola.it',    'Fisica',     '2012-09-01'),
('Marco',    'Conti',    'm.conti@scuola.it',    'Informatica','2021-09-01'),
('Elena',    'Ferrari',  NULL,                   'Matematica', '2023-09-01'),  -- senza email, nessun esame
('Maurizio', 'Lercio',   'm.lercio@scuola.it',   'Motoria',    '2023-09-01'); 

INSERT INTO classe (nome, anno, sezione, aula, coordinatore_id) VALUES
('1A', 1, 'A', 'A101', 2),
('2A', 2, 'A', 'A102', 1),
('3A', 3, 'A', 'B201', 3),
('3B', 3, 'B', 'B202', 5),
('5A', 5, 'A', 'C301', NULL);  -- classe senza coordinatore e senza studenti

INSERT INTO studente (nome, cognome, data_nascita, email, citta, classe_id) VALUES
('Luca',      'Esposito',  '2010-03-14', 'luca.esposito@studenti.it',  'Milano',  1),
('Giulia',    'Romano',    '2010-07-22', 'giulia.romano@studenti.it',  'Milano',  1),
('Francesco', 'Colombo',   '2010-11-05', 'f.colombo@studenti.it',      'Monza',   1),
('Sofia',     'Ricci',     '2009-01-30', 'sofia.ricci@studenti.it',    'Milano',  2),
('Alessandro','Marino',    '2009-05-18', 'a.marino@studenti.it',       'Bergamo', 2),
('Aurora',    'Greco',     '2009-09-09', NULL,                         'Milano',  2),
('Matteo',    'Bruno',     '2008-02-11', 'matteo.bruno@studenti.it',   'Monza',   3),
('Chiara',    'Gallo',     '2008-04-25', 'chiara.gallo@studenti.it',   'Milano',  3),
('Lorenzo',   'Costa',     '2008-08-03', 'l.costa@studenti.it',        'Como',    3),
('Martina',   'Fontana',   '2008-12-19', 'martina.fontana@studenti.it','Milano',  3),
('Andrea',    'Rinaldi',   '2008-06-07', 'andrea.rinaldi@studenti.it', 'Bergamo', 4),
('Beatrice',  'Moretti',   '2008-10-15', 'b.moretti@studenti.it',      'Milano',  4),
('Davide',    'Barbieri',  '2008-03-28', NULL,                         'Como',    4),
('Elisa',     'Lombardi',  '2009-12-01', 'elisa.lombardi@studenti.it', 'Milano',  NULL);  -- non assegnata

INSERT INTO esame (studente_id, insegnante_id, materia, data, voto, tipo) VALUES
-- 1A
(1, 1, 'Matematica', '2025-10-10', 7.0, 'scritto'),
(1, 2, 'Italiano',   '2025-10-15', 6.5, 'orale'),
(1, 3, 'Inglese',    '2025-11-03', 8.0, 'scritto'),
(2, 1, 'Matematica', '2025-10-10', 9.0, 'scritto'),
(2, 2, 'Italiano',   '2025-10-15', 8.5, 'orale'),
(2, 3, 'Inglese',    '2025-11-03', 9.5, 'scritto'),
(3, 1, 'Matematica', '2025-10-10', 4.5, 'scritto'),
(3, 2, 'Italiano',   '2025-10-15', 5.5, 'orale'),
(3, 1, 'Matematica', '2025-12-02', 6.0, 'orale'),
-- 2A
(4, 1, 'Matematica', '2025-10-12', 8.0, 'scritto'),
(4, 4, 'Storia',     '2025-11-20', 7.5, 'orale'),
(4, 3, 'Inglese',    '2025-11-05', 7.0, 'scritto'),
(5, 1, 'Matematica', '2025-10-12', 5.0, 'scritto'),
(5, 4, 'Storia',     '2025-11-20', 6.0, 'orale'),
(5, 3, 'Inglese',    '2025-11-05', NULL,'scritto'),  -- assente
(6, 1, 'Matematica', '2025-10-12', 10.0,'scritto'),
(6, 4, 'Storia',     '2025-11-20', 9.0, 'orale'),
-- 3A
(7, 5, 'Fisica',     '2025-10-20', 6.5, 'scritto'),
(7, 1, 'Matematica', '2025-10-22', 7.0, 'scritto'),
(7, 6, 'Informatica','2025-12-10', 8.0, 'scritto'),
(8, 5, 'Fisica',     '2025-10-20', 8.5, 'scritto'),
(8, 1, 'Matematica', '2025-10-22', 9.0, 'scritto'),
(8, 6, 'Informatica','2025-12-10', 9.5, 'scritto'),
(9, 5, 'Fisica',     '2025-10-20', 4.0, 'scritto'),
(9, 1, 'Matematica', '2025-10-22', 5.0, 'scritto'),
(9, 5, 'Fisica',     '2025-11-28', 6.0, 'orale'),
(10,2, 'Italiano',   '2025-11-12', 7.5, 'orale'),
(10,4, 'Storia',     '2025-11-25', 8.0, 'orale'),
-- 3B
(11,5, 'Fisica',     '2025-10-21', 7.0, 'scritto'),
(11,6, 'Informatica','2025-12-11', 10.0,'scritto'),
(11,3, 'Inglese',    '2025-11-06', 6.5, 'orale'),
(12,5, 'Fisica',     '2025-10-21', 5.5, 'scritto'),
(12,6, 'Informatica','2025-12-11', 7.0, 'scritto'),
(12,2, 'Italiano',   '2025-11-13', 8.0, 'orale');
-- Davide Barbieri (13) ed Elisa Lombardi (14) non hanno esami
