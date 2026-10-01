# Basi di Dati — Università di Verona

![Usato per l'esame](https://img.shields.io/badge/usato%20per%20l'esame-A.A.%202025--2026-2ea44f) ![Corso](https://img.shields.io/badge/UniVR-Basi%20di%20Dati-blue)

> Questi appunti sono stati usati per preparare l'esame di Basi di Dati dell'A.A. 2025/2026.

Materiale di studio per il corso di Basi di Dati (A.A. 2025/2026): lucidi, esercizi, temi d'esame, appunti riassuntivi, simulazioni e un piccolo ambiente per esercitarsi con SQL.

Moduli: **Teoria** · **Tecnologie** (Dr. Sara Migliorini) · **Laboratorio** (Dr. Beatrice Amico)

## Da dove iniziare

| Cosa vuoi fare | Dove andare |
|---|---|
| Capire cosa studiare e in che ordine | [GUIDA-ESAME.md](GUIDA-ESAME.md) |
| Trovare un file specifico | [INDEX.md](INDEX.md) (indice dettagliato di tutto il materiale) |
| Esercitarti con le query SQL | [07-Esercizi-SQL-Personali/](07-Esercizi-SQL-Personali/README.md) |

## Struttura

```
01-Teoria/                  lucidi + esercizi: ER, relazionale, document DB, algebra, calcolo
02-Tecnologie/              lucidi + esercizi: interni del DBMS (transazioni, indici, concorrenza, ottimizzazione)
03-Laboratorio/             8 lezioni: PostgreSQL, SQL, indici, concorrenza, Python, MongoDB
04-Esami/                   temi d'esame degli anni precedenti
05-Appunti-Riassunto/       appunti in PDF + sorgente LaTeX + dataset SQL d'esempio
06-Simulazioni/             6 temi inediti con soluzioni ragionate
07-Esercizi-SQL-Personali/  mini-DB PostgreSQL in Docker per provare le query
_Fuori-corso/               file non pertinenti al corso
```

## Esercitarsi con SQL

Serve Ubuntu, Linux o WSL2.

```bash
cd 07-Esercizi-SQL-Personali
./install.sh                         # una volta sola: installa Docker
cd scuola                            # oppure turismo, pokemon
watch -n 1 ./run.sh                  # modifica query.sql e vedi il risultato in tempo reale
```

Istruzioni complete e risoluzione dei problemi nel [README della cartella](07-Esercizi-SQL-Personali/README.md).

## Ringraziamenti

Un grazie speciale a **Fabio Irimie** ([fabiooo4/Uni](https://github.com/fabiooo4/Uni)): gli appunti in `05-Appunti-Riassunto/` (AppuntiBasiDati) vengono dal suo lavoro, molto curato e di grande aiuto per preparare l'esame.
