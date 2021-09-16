use cxdb;

select 
	concat( FirstName, ' ', LastName ) as 'Full name', username, 
	(select name from accesscontrol.AuthenticationProviders where id= AuthenticationProviderId) as 'Authentication Provider', 
	email, 
	(select substring( ( select ', ' + fullname
	from accesscontrol.teams 
	left join accesscontrol.TeamMembers on teamid = accesscontrol.teams.id 
	where accesscontrol.TeamMembers.userid = accesscontrol.AspNetUsers.id 
	for xml path ('') ) 
	, 3, 2000 ) ) as 'Teams'
	, 
	(select substring( 
	(select ', ' + name 
	from accesscontrol.AspNetRoles
	left join accesscontrol.AspNetUserRoles on accesscontrol.AspNetUserRoles.roleid = accesscontrol.aspnetroles.id 
	where accesscontrol.AspNetUserRoles.UserId = accesscontrol.aspnetusers.id
	for xml path ('') ) 
	, 3, 2000 ) ) as 'Roles'
	, LastLoginDate from accesscontrol.AspNetUsers
