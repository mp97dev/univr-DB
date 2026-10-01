# Esercizi SQL personali

Tre mini-database PostgreSQL (`scuola`, `turismo`, `pokemon`) in container Docker per esercitarsi a scrivere query. Funziona su Ubuntu, Linux in generale e WSL2.

```
install.sh        installa Docker e prepara l'ambiente (una volta sola)
common.sh         logica condivisa dei run.sh
scuola/           porta 5433 · tabelle: insegnante, classe, studente, esame
turismo/          porta 5434 · tabelle: turista, attrazione, prenotazione
pokemon/          porta 5435 · Pokédex reale (CSV in init/csv/), vista pokemon_with_type
  ├─ init/        schema + dati, caricati alla creazione del container
  ├─ query.sql    le tue query
  └─ run.sh       avvia il db ed esegue query.sql
```

## 1. Installazione

```bash
./install.sh
```

Installa Docker (se manca), ti aggiunge al gruppo `docker`, avvia il demone e scarica l'immagine `postgres:16-alpine`.
Se lo script ti ha aggiunto al gruppo, apri un nuovo terminale (o `newgrp docker`) così non serve più `sudo`.

> **WSL2**: va bene anche Docker Desktop per Windows con l'integrazione WSL attiva; in quel caso `install.sh` non è necessario.

## 2. Uso

Entra nella cartella del database e lancia:

```bash
cd scuola          # oppure turismo, pokemon
./run.sh
```

Al primo avvio crea il container e carica schema e dati, poi esegue `query.sql` e stampa il risultato.

| Comando | Effetto |
|---|---|
| `./run.sh` | esegue `query.sql` |
| `./run.sh altro.sql` | esegue un altro file |
| `./run.sh psql` | shell `psql` interattiva |
| `./run.sh reset` | ricrea il database da zero (utile dopo aver modificato `init/`) |
| `./run.sh stop` | ferma e rimuove il container |

Connessione da client esterni (DBeaver, VS Code...): `postgresql://scuola:scuola@localhost:5433/scuola` e `postgresql://turismo:turismo@localhost:5434/turismo`, `postgresql://pokemon:pokemon@localhost:5435/pokemon`.

Nota su `pokemon/`: `query.sql` contiene gli esercizi a livelli (tutti commentati con `--`), `es_corrected.sql` le soluzioni annotate (`./run.sh es_corrected.sql`). I CSV vengono dal [repo veekun/pokedex](https://github.com/veekun/pokedex).

## 3. Trucco: test delle query in tempo reale

Apri due terminali (o un terminale diviso accanto all'editor):

```bash
cd scuola
watch -n 1 ./run.sh
```

`watch` rilancia `run.sh` ogni secondo: modifichi `query.sql`, salvi, e nel giro di un secondo vedi il nuovo risultato (o l'errore di sintassi) senza toccare il terminale.

- Gli esercizi in `query.sql` sono commentati con `--`: togli i commenti alla query su cui lavori.
- Se fai `watch` su un file diverso: `watch -n 1 ./run.sh prova.sql`.
- `Ctrl+C` per uscire dal `watch`.

## Problemi comuni

- **`permission denied` / richiede la password di sudo a ogni run**: non sei nel gruppo `docker` nella sessione corrente → riapri il terminale. Dentro `watch` il prompt di sudo non funziona.
- **`Cannot connect to the Docker daemon` su WSL senza systemd**: `sudo service docker start`.
- **Porta già occupata**: cambia `PORT` nel `run.sh` della cartella, poi `./run.sh reset`.
- **Ho cambiato schema o dati in `init/`**: serve `./run.sh reset`, altrimenti il container esistente non li ricarica.
