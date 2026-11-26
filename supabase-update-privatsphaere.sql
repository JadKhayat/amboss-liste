-- Update: Privatsphäre (Fortschritt für andere sichtbar oder verborgen)
-- Einmal im Supabase SQL Editor ausführen. Kann gefahrlos mehrfach ausgeführt werden.
-- Vorhandene Nutzer bleiben sichtbar wie bisher, bis sie es selbst umstellen.

alter table public.nutzer add column if not exists oeffentlich boolean not null default true;

-- Haken eines Nutzers lesen: nur, wenn er sie freigegeben hat (sonst null)
create or replace function public.fortschritt(p_name text)
returns text[] language sql security definer set search_path = public as $$
  select fertig from public.nutzer where name = p_name and oeffentlich;
$$;

-- Eigener Stand mit PIN: Haken und Sichtbarkeit (bei falscher PIN null)
create or replace function public.mein_stand(p_name text, p_pin text)
returns json language plpgsql security definer set search_path = public as $$
declare r public.nutzer;
begin
  if not public._pin_ok(p_name, p_pin) then return null; end if;
  select * into r from public.nutzer where name = p_name;
  return json_build_object('fertig', r.fertig, 'oeffentlich', r.oeffentlich);
end $$;

-- Sichtbarkeit ändern (nur mit richtiger PIN)
create or replace function public.sichtbarkeit(p_name text, p_pin text, p_oeffentlich boolean)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  if not public._pin_ok(p_name, p_pin) then return false; end if;
  update public.nutzer set oeffentlich = coalesce(p_oeffentlich, true) where name = p_name;
  return true;
end $$;

grant execute on function public.mein_stand(text, text) to anon, authenticated;
grant execute on function public.sichtbarkeit(text, text, boolean) to anon, authenticated;
