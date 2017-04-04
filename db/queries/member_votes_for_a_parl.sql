-- get a list of all votes a member has made for a particular parliament

select
c.start_date, a.name, a.is_law, a.session_number, vs.passed as law_passed, a.is_public, a.made_public_at, d.first_name, vr.present, vr.vote
from
conferences as c
inner join agendas as a on a.conference_id = c.id
inner join voting_sessions as vs on vs.agenda_id = a.id
inner join voting_results as vr on vr.voting_session_id = vs.id
inner join delegates as d on d.id = vr.delegate_id
where 
a.parliament_id = 3
and d.all_delegate_id = 578
order by c.start_date desc
