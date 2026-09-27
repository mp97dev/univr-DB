# Quiz — Informatica / Basi di dati

> Domande e risposte estratte dal contenuto fornito.  
> Le formulazioni sono state ripulite dal markup HTML e dal boilerplate del quiz, senza aggiungere informazioni non presenti nella fonte.


## 1. Create table if not exists

**Risposta:**

> Varie opzioni dove cambia la posizione del nome della tabella


CREATE TABLE IF NOT EXISTS nome è giusta

---

## 2. Cosa fa t1 e t2 timestamp insieme?

**Risposta:**

> t1-t2 è un intervallo
t1+t2 non si può fare

---

## 3. Quale modalità di isolamento ha 2pl non solo per le strutture ma anche per le letture, ed ha anche il blocco del predicato?

**Risposta:**

> Serialization

---

## 4. Quale è la minima quantità di indici in un b+-tree di fanout n?

**Risposta:**

> (n-1)/2

---

## 5. erché è consigliabile avere un numero dispari di membri votanti in un replica set?

**Risposta:**

> Per evitare situazioni di parità nei voti durante le elezioni del primario

---

## 6. Quale anomalia corrisponde al comportamento in cui accessi successivi allo stesso dato all'interno di una transazione ritornano valori diversi?

**Risposta:**

> Lettura inconsistente

---

## 7. Data la dichiarazione
nome CHAR(6)
Cosa succede se in un UPDATE si scrive
SET nome = '100.1'?
nome assume valore '100.1' e viene rappresentato internamente come '_100.1' dove _ rappresenta uno spazio.
Si verifica un errore perchè non è stato fatto un cast.
nome assume valore '100.10'.
È una stringa non un decimale!
nome assume valore '100.1' e viene rappresentato internamente come '100.1_' dove _ rappresenta uno spazio.

**Risposta:**

> nome assume valore '100.1' e viene rappresentato internamente come '100.1_' dove _ rappresenta uno spazio.

---

## 8. Come verificare se uno schedule è csr

**Risposta:**

> Controllare se nn contiene cicli cioè deve essere aciclico

---

## 9. come fare operazione di ricerca usando db.find(lt)

**Risposta:**

> soluzione: db.nome_collezione.find({ nome_del_campo: { $lt: 10 } })

---

## 10. una considerazione su hash based join:

**Risposta:**

> SOL: se h(t_r.J) != h(t_s.J), allora sicuramente si ha t_r.J = ts.J

---

## 11. cosa fa un nodo primario di un replica set:

**Risposta:**

> SOL: Gestisce le operazione di scrittura lettura e tiene traccia delle operazioni in log (oplog)

---

## 12. qual’è la complessità dell’algoritmo di test csr?

**Opzioni riportate:**

- risposte:
- LINEARE  ✓
- logaritmica ✖️
- quadratica ✖️
- esponenziale ✖️

**Risposta:**

> - LINEARE

---

## 13. Indice su attributi in where

**Risposta:**

> where nome='carlo' OR lower(cognome)<'C' 
su tabella persona. Scegliere indice (corretta la prima):
- create index idx1 on persona(nome); create index idx2 on persona(cognome)
- create index idx on persona(nome, cognome) 
- create index idx on persona(nome,lower(cognome))
- create index idx on nome,lower(cognome)

---
