/* total possible votes */
select
count(*)
from
agendas as a 
inner join conferences as c on c.id = a.conference_id
inner join upload_files as up on up.id = c.upload_file_id
inner join voting_sessions as vs on vs.agenda_id = a.id
where up.is_deleted = 0
and up.parliament_id = 1;

/* votes by session */
/* only get 1st and 2nd session counts for items that are passed laws */
select distinct count(*)
	from 
  	agendas as a 
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
  and up.parliament_id = 1
	and a.is_law = 1 
	and a.is_public = 1
	and a.session_number = 'III მოსმენა'
	and a.session_number1_id is not null
;


select distinct count(*)
from 
agendas as a 
inner join conferences as c on c.id = a.conference_id
inner join upload_files as up on up.id = c.upload_file_id
where up.is_deleted = 0 
and up.parliament_id = 1
and a.is_law = 1 
and a.is_public = 1
and a.session_number = 'III მოსმენა'
and a.session_number2_id is not null
;

select
count(*)
from
agendas as a 
inner join conferences as c on c.id = a.conference_id
inner join upload_files as up on up.id = c.upload_file_id
inner join voting_sessions as vs on vs.agenda_id = a.id
where up.is_deleted = 0 
and up.parliament_id = 1
and a.is_law = 1 
and a.is_public = 1 
and a.session_number = 'III მოსმენა';

select
count(*)
from
agendas as a 
inner join conferences as c on c.id = a.conference_id
inner join upload_files as up on up.id = c.upload_file_id
inner join voting_sessions as vs on vs.agenda_id = a.id
where up.is_deleted = 0 
and up.parliament_id = 1
and a.is_law = 1 
and a.is_public = 1 
and a.session_number = 'ერთი მოსმენით';




/* total votes member has made */
select
ad.first_name, x.count
from
all_delegates as ad
left join (
	select
	ad.id, count(*) as count
	from
	all_delegates as ad
	inner join delegates as d on d.all_delegate_id = ad.id
	inner join voting_results as vr on vr.delegate_id = d.id
	inner join voting_sessions as vs on vs.id = vr.voting_session_id
	inner join agendas as a on a.id = vs.agenda_id
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
	and up.parliament_id = 1
	and ad.parliament_id = 1
	and vr.present = 1
	and vr.vote is not null
	group by ad.id
) as x on x.id = ad.id
where ad.parliament_id = 1
order by ad.first_name;


/* total 1st votes member has made */
select
ad.first_name, x.count
from
all_delegates as ad
left join (
	select
	ad.id, count(*) as count
	from
	all_delegates as ad
	inner join delegates as d on d.all_delegate_id = ad.id
	inner join voting_results as vr on vr.delegate_id = d.id
	inner join voting_sessions as vs on vs.id = vr.voting_session_id
	inner join agendas as a on a.id = vs.agenda_id
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
	and up.parliament_id = 1
	and ad.parliament_id = 1
	and a.session_number = 'I მოსმენა'
	and a.id in (select distinct session_number1_id 
		from 
	  	agendas as a 
		inner join conferences as c on c.id = a.conference_id
		inner join upload_files as up on up.id = c.upload_file_id
		where up.is_deleted = 0 
		and up.parliament_id = 1
		and a.is_law = 1 
		and a.is_public = 1 
		and a.session_number = 'III მოსმენა'
		and a.session_number1_id is not null)
	and vr.present = 1
	and vr.vote is not null
	group by ad.id
) as x on x.id = ad.id
where ad.parliament_id = 1
order by ad.first_name;

/* total 2nd votes member has made */
select
ad.first_name, x.count
from
all_delegates as ad
left join (
	select
	ad.id, count(*) as count
	from
	all_delegates as ad
	inner join delegates as d on d.all_delegate_id = ad.id
	inner join voting_results as vr on vr.delegate_id = d.id
	inner join voting_sessions as vs on vs.id = vr.voting_session_id
	inner join agendas as a on a.id = vs.agenda_id
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
	and up.parliament_id = 1
	and ad.parliament_id = 1
	and a.session_number = 'I მოსმენა'
	and a.id in (select distinct session_number1_id 
		from 
	  	agendas as a 
		inner join conferences as c on c.id = a.conference_id
		inner join upload_files as up on up.id = c.upload_file_id
		where up.is_deleted = 0 
		and up.parliament_id = 1
		and a.is_law = 1 
		and a.is_public = 1 
		and a.session_number = 'III მოსმენა'
		and a.session_number2_id is not null)
	and vr.present = 1
	and vr.vote is not null
	group by ad.id
) as x on x.id = ad.id
where ad.parliament_id = 1
order by ad.first_name;


/* total 3rd votes member has made */
select
ad.first_name, x.count
from
all_delegates as ad
left join (
	select
	ad.id, count(*) as count
	from
	all_delegates as ad
	inner join delegates as d on d.all_delegate_id = ad.id
	inner join voting_results as vr on vr.delegate_id = d.id
	inner join voting_sessions as vs on vs.id = vr.voting_session_id
	inner join agendas as a on a.id = vs.agenda_id
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
	and up.parliament_id = 1
	and ad.parliament_id = 1
	and a.session_number = 'III მოსმენა'
	and a.is_law = 1 
	and a.is_public = 1 
	and vr.present = 1
	and vr.vote is not null
	group by ad.id
) as x on x.id = ad.id
where ad.parliament_id = 1
order by ad.first_name;
  
  
  
/* total 1 session only votes member has made */
select
ad.first_name, x.count
from
all_delegates as ad
left join (
	select
	ad.id, count(*) as count
	from
	all_delegates as ad
	inner join delegates as d on d.all_delegate_id = ad.id
	inner join voting_results as vr on vr.delegate_id = d.id
	inner join voting_sessions as vs on vs.id = vr.voting_session_id
	inner join agendas as a on a.id = vs.agenda_id
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
	and up.parliament_id = 1
	and ad.parliament_id = 1
	and a.session_number = 'ერთი მოსმენით'
	and a.is_law = 1 
	and a.is_public = 1 
	and vr.present = 1
	and vr.vote is not null
	group by ad.id
) as x on x.id = ad.id
where ad.parliament_id = 1
order by ad.first_name;
    
    
    
    
/*************************************************************/   
/*************************************************************/   
/*************************************************************/   
/* all votes for all members in 1st parliament */
	select
	ad.first_name, ad.started_at, ad.ended_at,
	count(vr.vote) as total_votes,
	sum(case when vr.vote = 1 then 1 else 0 end) as yes_votes,
	sum(case when vr.vote = 3 then 1 else 0 end) as no_votes,
	sum(case when vr.vote = 0 then 1 else 0 end) as abstain_votes
	from
	all_delegates as ad
	inner join delegates as d on d.all_delegate_id = ad.id
	inner join voting_results as vr on vr.delegate_id = d.id
	inner join voting_sessions as vs on vs.id = vr.voting_session_id
	inner join agendas as a on a.id = vs.agenda_id
	inner join conferences as c on c.id = a.conference_id
	inner join upload_files as up on up.id = c.upload_file_id
	where up.is_deleted = 0 
	and up.parliament_id = 1
	and ad.parliament_id = 1
	and vr.present = 1
	and vr.vote is not null
	group by ad.first_name, ad.started_at, ad.ended_at
	order by ad.first_name;

/************************************************/
/* total number of possible votes */
/************************************************/
select
count(vs.id) as num_voting_sessions
from 
upload_files as up
inner join conferences as c on c.upload_file_id = up.id
inner join agendas as a on a.conference_id = c.id
inner join voting_sessions as vs on vs.agenda_id = a.id
where up.parliament_id = 1
and up.is_deleted = 0 ;
