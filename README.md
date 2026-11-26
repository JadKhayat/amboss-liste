# Amboss-Liste

Amboss-Kapitel zur Vorbereitung auf die Pflichtkurse im klinischen Abschnitt (Uni Münster), Semester für Semester.

- `index.html`: die Webseite (jadkhayat.github.io/amboss-liste)
- `kurse.json`: Kurse mit Kapiteln
- `supabase.sql`: Nutzer mit PIN und Haken

## Semester

Oben auf der Seite wählt man das Semester. Die Kurse werden über ihr Datum zugeordnet:
Wintersemester von Oktober bis März, Sommersemester von April bis September.
Neue Kurse einfach wie bisher an `kurse` anhängen, ein neues Semester erscheint dann von selbst.

Die Beschreibung steht in `kurse.json` unter `"semester"`, z. B. `{"WS 26/27": "1. klinisches Semester"}`.
Spätere Semester werden ab dort automatisch weitergezählt (SS 27 = 2. klinisches Semester usw.).
Stimmt die Zählung einmal nicht (z. B. Auslandssemester), dort einen eigenen Eintrag ergänzen.
Ein Kurs außerhalb der üblichen Zeiten kann mit `"semester": "WS 26/27"` fest zugeordnet werden.
Die Haken gelten über alle Semester: Ein Kapitel, das schon gelesen ist, bleibt abgehakt, wenn es später wieder vorkommt.
