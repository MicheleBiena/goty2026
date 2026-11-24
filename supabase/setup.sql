-- Eseguire nel SQL Editor del progetto Supabase. Una sola volta su un progetto nuovo.
begin;
create table public.award_vote_options (
  category_id text not null,
  nominee_id text not null,
  primary key (category_id, nominee_id)
);
create table public.award_votes (
  voter_id uuid not null references auth.users(id) on delete cascade,
  category_id text not null,
  nominee_id text not null,
  created_at timestamptz not null default now(),
  primary key (voter_id, category_id),
  foreign key (category_id, nominee_id) references public.award_vote_options(category_id, nominee_id)
);
create table public.award_voting_settings (
  id boolean primary key default true check (id),
  is_open boolean not null default true
);
insert into public.award_voting_settings(id, is_open) values (true, true);
insert into public.award_vote_options(category_id, nominee_id) values
  ('123312108', '123312108-1'),
  ('123312108', '123312108-2'),
  ('123312108', '123312108-3'),
  ('123312108', '123312108-4'),
  ('123312108', '123312108-5'),
  ('123312108', '123312108-6'),
  ('123312108', '123312108-7'),
  ('123312108', '123312108-8'),
  ('123312108', '123312108-9'),
  ('123312108', '123312108-10'),
  ('123312108', '123312108-11'),
  ('123312108', '123312108-12'),
  ('123312108', '123312108-13'),
  ('123312108', '123312108-14'),
  ('123312108', '123312108-15'),
  ('123312108', '123312108-16'),
  ('123312108', '123312108-17'),
  ('123312108', '123312108-18'),
  ('868664846', '868664846-1'),
  ('868664846', '868664846-2'),
  ('868664846', '868664846-3'),
  ('868664846', '868664846-4'),
  ('868664846', '868664846-5'),
  ('868664846', '868664846-6'),
  ('868664846', '868664846-7'),
  ('868664846', '868664846-8'),
  ('868664846', '868664846-9'),
  ('868664846', '868664846-10'),
  ('868664846', '868664846-11'),
  ('868664846', '868664846-12'),
  ('868664846', '868664846-13'),
  ('868664846', '868664846-14'),
  ('664463426', '664463426-1'),
  ('664463426', '664463426-2'),
  ('664463426', '664463426-3'),
  ('664463426', '664463426-4'),
  ('664463426', '664463426-5'),
  ('664463426', '664463426-6'),
  ('664463426', '664463426-7'),
  ('664463426', '664463426-8'),
  ('664463426', '664463426-9'),
  ('664463426', '664463426-10'),
  ('1276262471', '1276262471-1'),
  ('1276262471', '1276262471-2'),
  ('1276262471', '1276262471-3'),
  ('1276262471', '1276262471-4'),
  ('1276262471', '1276262471-5'),
  ('1276262471', '1276262471-6'),
  ('1276262471', '1276262471-7'),
  ('111712000', '111712000-1'),
  ('111712000', '111712000-2'),
  ('111712000', '111712000-3'),
  ('111712000', '111712000-4'),
  ('111712000', '111712000-5'),
  ('111712000', '111712000-6'),
  ('111712000', '111712000-7'),
  ('111712000', '111712000-8'),
  ('111712000', '111712000-9'),
  ('111712000', '111712000-10'),
  ('111712000', '111712000-11'),
  ('111712000', '111712000-12'),
  ('111712000', '111712000-13'),
  ('111712000', '111712000-14'),
  ('111712000', '111712000-15'),
  ('111712000', '111712000-16'),
  ('111712000', '111712000-17'),
  ('111712000', '111712000-18'),
  ('1008948052', '1008948052-1'),
  ('1008948052', '1008948052-2'),
  ('1008948052', '1008948052-3'),
  ('1008948052', '1008948052-4'),
  ('1008948052', '1008948052-5'),
  ('1008948052', '1008948052-6'),
  ('1537952530', '1537952530-1'),
  ('1537952530', '1537952530-2'),
  ('1537952530', '1537952530-3'),
  ('1537952530', '1537952530-4'),
  ('1537952530', '1537952530-5'),
  ('12528539', '12528539-1'),
  ('12528539', '12528539-2'),
  ('12528539', '12528539-3'),
  ('1146935305', '1146935305-1'),
  ('1146935305', '1146935305-2'),
  ('1146935305', '1146935305-3'),
  ('1146935305', '1146935305-4'),
  ('1146935305', '1146935305-5'),
  ('1146935305', '1146935305-6'),
  ('1146935305', '1146935305-7'),
  ('1146935305', '1146935305-8'),
  ('1022929596', '1022929596-1'),
  ('1022929596', '1022929596-2'),
  ('1022929596', '1022929596-3'),
  ('1022929596', '1022929596-4'),
  ('1022929596', '1022929596-5'),
  ('1022929596', '1022929596-6'),
  ('1022929596', '1022929596-7'),
  ('1022929596', '1022929596-8'),
  ('1022929596', '1022929596-9'),
  ('1022929596', '1022929596-10'),
  ('1022929596', '1022929596-11'),
  ('1022929596', '1022929596-12'),
  ('1022929596', '1022929596-13'),
  ('1022929596', '1022929596-14'),
  ('1022929596', '1022929596-15'),
  ('1022929596', '1022929596-16'),
  ('1022929596', '1022929596-17'),
  ('1022929596', '1022929596-18'),
  ('1022929596', '1022929596-19'),
  ('1022929596', '1022929596-20');
-- Le tabelle non sono accessibili direttamente dal browser, nemmeno in lettura.
alter table public.award_vote_options enable row level security;
alter table public.award_votes enable row level security;
alter table public.award_voting_settings enable row level security;
revoke all on public.award_vote_options, public.award_votes, public.award_voting_settings from public, anon, authenticated;

-- Restituisce esclusivamente i voti dell'utente autenticato.
create function public.award_my_votes()
returns table(category_id text, nominee_id text)
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or coalesce(auth.jwt()->'app_metadata'->>'provider', '') <> 'twitch' then
    raise exception 'Accesso Twitch richiesto';
  end if;
  return query select v.category_id, v.nominee_id from public.award_votes v where v.voter_id = auth.uid();
end;
$$;

-- Accetta un oggetto categoria -> candidato e registra tutto in una transazione.
-- La chiave primaria impedisce un secondo voto nella stessa categoria per account.
create function public.award_cast_votes(choices jsonb)
returns integer language plpgsql security definer set search_path = '' as $$
declare item record; inserted integer := 0;
begin
  if auth.uid() is null or coalesce(auth.jwt()->'app_metadata'->>'provider', '') <> 'twitch' then
    raise exception 'Accesso Twitch richiesto';
  end if;
  if not coalesce((select is_open from public.award_voting_settings where id = true), false) then
    raise exception 'Votazioni chiuse';
  end if;
  if choices is null or jsonb_typeof(choices) <> 'object' then
    raise exception 'Scheda non valida';
  end if;
  if (select count(*) from jsonb_object_keys(choices)) not between 1 and 100 then
    raise exception 'Scheda vuota o troppo grande';
  end if;
  if exists (select 1 from jsonb_each(choices) as j(key, value) where jsonb_typeof(j.value) <> 'string') then
    raise exception 'Scheda non valida';
  end if;
  for item in select j.key as category_id, j.value as nominee_id from jsonb_each_text(choices) as j loop
    if not exists (select 1 from public.award_vote_options o where o.category_id = item.category_id and o.nominee_id = item.nominee_id) then
      raise exception 'Candidato non valido';
    end if;
    insert into public.award_votes(voter_id, category_id, nominee_id)
      values (auth.uid(), item.category_id, item.nominee_id);
    inserted := inserted + 1;
  end loop;
  return inserted;
exception when unique_violation then
  raise exception 'Hai gia votato in una delle categorie selezionate';
end;
$$;
revoke all on function public.award_my_votes() from public, anon;
revoke all on function public.award_cast_votes(jsonb) from public, anon;
grant execute on function public.award_my_votes() to authenticated;
grant execute on function public.award_cast_votes(jsonb) to authenticated;
commit;

-- Per chiudere: update public.award_voting_settings set is_open = false where id = true;
-- Per esportare i voti nel SQL Editor:
-- select category_id, nominee_id, count(*) as voti from public.award_votes group by category_id, nominee_id order by category_id, voti desc;
