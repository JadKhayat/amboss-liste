-- Amboss-Liste: Benutzer mit PIN und Fortschritt (Haken)
-- Einmal im Supabase SQL Editor ausführen.
-- Die Tabelle ist von außen nicht direkt erreichbar (Row Level Security ohne Regeln).
-- Die Webseite nutzt nur die Funktionen unten; die PIN wird dort geprüft und nur verschlüsselt gespeichert.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.nutzer (
  name          text primary key check (char_length(name) between 1 and 40),
  pin_hash      text not null,
  fertig        text[] not null default '{}',
  fehlversuche  int not null default 0,
  gesperrt_bis  timestamptz,
  erstellt      timestamptz not null default now()
);

alter table public.nutzer enable row level security;
revoke all on table public.nutzer from anon, authenticated;

-- Liste aller Namen (für die Auswahl)
create or replace function public.liste_nutzer()
returns setof text language sql security definer set search_path = public as $$
  select name from public.nutzer order by lower(name);
$$;

-- Haken eines Nutzers lesen (für alle sichtbar)
create or replace function public.fortschritt(p_name text)
returns text[] language sql security definer set search_path = public as $$
  select fertig from public.nutzer where name = p_name;
$$;

-- Interne Hilfsfunktion: PIN prüfen, nach 5 Fehlversuchen 15 Minuten sperren
create or replace function public._pin_ok(p_name text, p_pin text)
returns boolean language plpgsql security definer set search_path = public, extensions as $$
declare r public.nutzer;
begin
  select * into r from public.nutzer where name = p_name for update;
  if not found then raise exception 'Unbekannter Name'; end if;
  if r.gesperrt_bis is not null and r.gesperrt_bis > now() then
    raise exception 'Zu viele falsche PINs. Bitte in 15 Minuten erneut versuchen.';
  end if;
  if r.pin_hash = crypt(p_pin, r.pin_hash) then
    update public.nutzer set fehlversuche = 0, gesperrt_bis = null where name = p_name;
    return true;
  end if;
  update public.nutzer
     set fehlversuche = r.fehlversuche + 1,
         gesperrt_bis = case when r.fehlversuche + 1 >= 5 then now() + interval '15 minutes' else null end
   where name = p_name;
  return false;
end $$;
revoke all on function public._pin_ok(text, text) from public, anon, authenticated;

-- Neuen Nutzer anlegen (PIN: 4 bis 8 Ziffern)
create or replace function public.registrieren(p_name text, p_pin text)
returns boolean language plpgsql security definer set search_path = public, extensions as $$
begin
  p_name := btrim(p_name);
  if char_length(p_name) < 1 or char_length(p_name) > 40 then raise exception 'Name: 1 bis 40 Zeichen'; end if;
  if p_pin !~ '^[0-9]{4,8}$' then raise exception 'PIN: 4 bis 8 Ziffern'; end if;
  if (select count(*) from public.nutzer) >= 100 then raise exception 'Maximale Nutzerzahl erreicht'; end if;
  insert into public.nutzer(name, pin_hash) values (p_name, crypt(p_pin, gen_salt('bf')));
  return true;
exception when unique_violation then
  raise exception 'Diesen Namen gibt es schon';
end $$;

-- PIN prüfen (beim Einloggen)
create or replace function public.pin_pruefen(p_name text, p_pin text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  return public._pin_ok(p_name, p_pin);
end $$;

-- Haken speichern (nur mit richtiger PIN)
create or replace function public.speichern(p_name text, p_pin text, p_fertig text[])
returns boolean language plpgsql security definer set search_path = public as $$
begin
  if coalesce(array_length(p_fertig, 1), 0) > 2000 then raise exception 'Zu viele Einträge'; end if;
  if exists (select 1 from unnest(p_fertig) x where char_length(x) > 40) then raise exception 'Ungültiger Eintrag'; end if;
  -- bei falscher PIN false zurückgeben (nicht abbrechen), damit der Fehlversuch gezählt bleibt
  if not public._pin_ok(p_name, p_pin) then return false; end if;
  update public.nutzer set fertig = p_fertig where name = p_name;
  return true;
end $$;

grant execute on function public.liste_nutzer() to anon, authenticated;
grant execute on function public.fortschritt(text) to anon, authenticated;
grant execute on function public.registrieren(text, text) to anon, authenticated;
grant execute on function public.pin_pruefen(text, text) to anon, authenticated;
grant execute on function public.speichern(text, text, text[]) to anon, authenticated;
