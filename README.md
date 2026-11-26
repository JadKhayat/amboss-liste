# Lernplaner

Amboss-Kapitel zur Vorbereitung auf die Pflichtkurse im klinischen Abschnitt (Uni Münster), Semester für Semester.

- `index.html`: die Webseite (jadkhayat.github.io/amboss-liste) mit Startseite (Übersicht), Amboss-Liste (`#liste`) und Profil (`#profil`: Anmeldung, PIN ändern, Semester, Hell/Dunkel, Privatsphäre)
- `kurse.json`: Kurse mit Kapiteln
- `dateien.json` und Ordner `skripte/`: Skripte und Unterlagen für den Tab „Skripte“
- `supabase.sql`: Nutzer mit PIN, Haken und Privatsphäre (vollständige Einrichtung)
- `supabase-update.sql`: Update für eine bestehende Datenbank (Privatsphäre, PIN ändern)

## Semester

Das Semester wählt man unter „Profil“. Die Kurse werden über ihr Datum zugeordnet:
Wintersemester von Oktober bis März, Sommersemester von April bis September.
Neue Kurse einfach wie bisher an `kurse` anhängen, ein neues Semester erscheint dann von selbst.

Die Beschreibung steht in `kurse.json` unter `"semester"`, z. B. `{"WS 26/27": "1. klinisches Semester"}`.
Spätere Semester werden ab dort automatisch weitergezählt (SS 27 = 2. klinisches Semester usw.).
Stimmt die Zählung einmal nicht (z. B. Auslandssemester), dort einen eigenen Eintrag ergänzen.
Ein Kurs außerhalb der üblichen Zeiten kann mit `"semester": "WS 26/27"` fest zugeordnet werden.
Die Haken gelten über alle Semester: Ein Kapitel, das schon gelesen ist, bleibt abgehakt, wenn es später wieder vorkommt.

## Startseite

Zeigt den nächsten Kurs, diese und nächste Woche, Kurse mit offenen Kapiteln zum Nachholen, den Fortschritt je Fach und die Quellen.
Die Quellen stehen oben im Skript von `index.html` in `QUELLEN`.

## Skripte

Eigene Skripte als Datei unter `skripte/<Fach>/` ablegen und in `dateien.json` eintragen:

```json
{"t": "POL Fall 3 – Lernskript", "datei": "skripte/Allgemeine Pharmakologie/POL Fall 3.pdf",
 "fach": "Allgemeine Pharmakologie", "kurs": "2026-11-20-pol-4", "art": "Eigenes Skript"}
```

- `kurs` (optional): ID aus `kurse.json`. Dann erscheint die Datei auch in der Amboss-Liste beim Kurs und im richtigen Semester.
- `datum` (optional, ohne Kurs): ordnet die Datei einem Semester zu. Ohne Kurs und Datum erscheint sie in jedem Semester.
- Statt `datei` geht auch `url` (z. B. Link zu Ilias oder OneDrive). Offizielle Unterlagen der Uni nur verlinken, nicht hochladen: Die Seite ist öffentlich.
