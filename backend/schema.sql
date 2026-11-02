-- Aktionen: Datenbank für Registrierung, Lieblingsartikel und Benachrichtigungen
-- Einmalig in Supabase ausführen: SQL Editor → New query → alles einfügen → Run

-- 1) Profil je registrierter Person (wird bei der Registrierung automatisch angelegt)
create table if not exists public.profile (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  registriert_am timestamptz not null default now(),
  zuletzt_aktiv timestamptz not null default now(),
  mail_benachrichtigung boolean not null default true
);

-- 2) Lieblingsartikel (Suchbegriffe wie «Skyr», «Red Bull»)
create table if not exists public.favoriten (
  user_id uuid not null references auth.users (id) on delete cascade,
  begriff text not null check (char_length(begriff) between 2 and 40),
  erstellt_am timestamptz not null default now(),
  primary key (user_id, begriff)
);

-- 3) Geräte für Push-Benachrichtigungen (iPhone-App oder Browser)
create table if not exists public.geraete (
  token text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  plattform text not null check (plattform in ('ios', 'web')),
  abo jsonb,                       -- bei Web Push: das ganze Abo-Objekt
  erstellt_am timestamptz not null default now(),
  zuletzt_gesehen timestamptz not null default now()
);

-- Jede Person sieht und ändert nur ihre eigenen Zeilen
alter table public.profile   enable row level security;
alter table public.favoriten enable row level security;
alter table public.geraete   enable row level security;

drop policy if exists "eigenes profil" on public.profile;
create policy "eigenes profil" on public.profile for all
  using (auth.uid() = id) with check (auth.uid() = id);
drop policy if exists "eigene favoriten" on public.favoriten;
create policy "eigene favoriten" on public.favoriten for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "eigene geraete" on public.geraete;
create policy "eigene geraete" on public.geraete for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Profil automatisch anlegen, sobald sich jemand registriert
create or replace function public.neues_profil() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profile (id, email) values (new.id, new.email) on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists bei_registrierung on auth.users;
create trigger bei_registrierung after insert on auth.users
  for each row execute function public.neues_profil();

-- Auswertungen nur für dich (Schema «admin» ist von der App aus nicht erreichbar)
create schema if not exists admin;
revoke all on schema admin from anon, authenticated;

create or replace view admin.registrierungen as
  select p.email, p.registriert_am, p.zuletzt_aktiv,
         count(distinct f.begriff) as lieblingsartikel,
         count(distinct g.token)   as geraete,
         string_agg(distinct g.plattform, ', ') as plattformen
  from public.profile p
  left join public.favoriten f on f.user_id = p.id
  left join public.geraete  g on g.user_id = p.id
  group by p.id order by p.registriert_am desc;

create or replace view admin.registrierungen_pro_woche as
  select woche, neu, sum(neu) over (order by woche) as gesamt
  from (select date_trunc('week', registriert_am)::date as woche, count(*) as neu
        from public.profile group by 1) w
  order by woche desc;

create or replace view admin.beliebteste_artikel as
  select lower(begriff) as begriff, count(*) as personen
  from public.favoriten group by 1 order by 2 desc, 1;

-- Konto selbst löschen (von Apple für Apps mit Registrierung vorgeschrieben).
-- Löscht die Person; Profil, Lieblingsartikel und Geräte verschwinden automatisch mit.
create or replace function public.konto_loeschen() returns void
language sql security definer set search_path = '' as $$
  delete from auth.users where id = auth.uid();
$$;
revoke all on function public.konto_loeschen() from public, anon;
grant execute on function public.konto_loeschen() to authenticated;
