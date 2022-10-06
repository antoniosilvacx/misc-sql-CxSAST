use cxdb;

IF OBJECT_ID('tempdb..#tempEnvChange') IS NOT NULL
  DROP TABLE #tempEnvChange;
IF OBJECT_ID('tempdb..#tempEnvActions') IS NOT NULL
  DROP TABLE #tempEnvActions;
IF OBJECT_ID('tempdb..#tempEnvTables') IS NOT NULL
  DROP TABLE #tempEnvTables;


create table #tempEnvChange
(
	ID INT IDENTITY(1,1),
	Src VARCHAR(max) not null,
	Dst VARCHAR(max)
);

create table #tempEnvTables
(
	ID INT IDENTITY(1,1),
	[Table] VARCHAR(256) not null,
	[Column] VARCHAR(256) not null
);


create table #tempEnvActions
(
	[Action] VARCHAR(max) not null
); 



insert into #tempEnvChange VALUES( 'prod.fqdn.internal', 'preprod.fqdn.internal' );
insert into #tempEnvChange VALUES( '10.0.0.1', '10.1.0.1' );

insert into #tempEnvChange VALUES( 'prod-manager1.fqdn.internal', 'preprod-manager1.fqdn.internal' );
insert into #tempEnvChange VALUES( '10.0.1.1', '10.1.1.1' );

insert into #tempEnvChange VALUES( 'prod-manager2.fqdn.internal', null ); -- deleting because only 1 manager in preprod
insert into #tempEnvChange VALUES( '10.0.1.2', null );

-- accesscontrol.SamlIdentityProviders.[CertificateFileName]

insert into #tempEnvChange VALUES( 'prod.cer', 'preprod.crt' );
-- accesscontrol.SamlIdentityProviders.[EncryptedCertificate]
insert into #tempEnvChange VALUES( '123', '321' );

-- active MQ connection string
insert into #tempEnvChange VALUES( 'failover:(tcp://10.0.2.1:61616,tcp://10.0.2.2:61616,tcp://10.0.2.3:61616)', 'failover:(tcp://10.1.2.1:61616,tcp://10.1.2.2:61616)' );
insert into #tempEnvChange VALUES( '\\10.0.3.1\Cx', '\\10.1.3.1\Cx' );

-- CxComponentConfiguration MessageQueuePassword
insert into #tempEnvChange VALUES( '123', '321' );
-- OSA org token
insert into #tempEnvChange VALUES( 'a-b-c-d-e', 'e-d-c-b-a' );

insert into #tempEnvTables VALUES( 'accesscontrol.ClientCorsOrigins', 'Origin' );
insert into #tempEnvTables VALUES( 'accesscontrol.ClientPostLogoutRedirectUris', 'PostLogoutRedirectUri' );
insert into #tempEnvTables VALUES( 'accesscontrol.ClientRedirectUris', 'RedirectUri' );
insert into #tempEnvTables VALUES( 'accesscontrol.ConfigurationItems', '[Value]' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlIdentityProviders', 'CertificateFileName' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlIdentityProviders', 'EncryptedCertificate' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlIdentityProviders', 'Issuer' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlIdentityProviders', 'LoginUrl' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlServiceProvider', 'EncryptedCertificate' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlServiceProvider', 'EncryptedCertificatePassword' );
insert into #tempEnvTables VALUES( 'accesscontrol.SamlServiceProvider', 'Issuer' );
insert into #tempEnvTables VALUES( 'config.CxEngineConfigurationKeysMeta', 'DefaultValue' );
insert into #tempEnvTables VALUES( 'CxComponentConfiguration', '[Value]' );

declare @ChangeCursorID INT;
declare @MaxChangeCursorID INT;
select @MaxChangeCursorID = count(*) from #tempEnvChange;

declare @TableCursorID INT;
declare @MaxTableCursorID INT;
select @MaxTableCursorID = count(*) from #tempEnvTables;

declare @Src VARCHAR(max);
declare @Dst VARCHAR(max);
declare @Tbl VARCHAR(256);
declare @Clm VARCHAR(256);

declare @TableMatchCheckFlag INT = 0;
declare @TableMatchCheckSQL NVARCHAR(max);

select @TableCursorID = 0;
while @TableCursorID < @MaxTableCursorID
begin
	select top 1 @TableCursorID = id, @Tbl = [Table], @Clm = [Column] from #tempEnvTables where id > @TableCursorID order by id asc;

	select @ChangeCursorID = 0;
	while @ChangeCursorID < @MaxChangeCursorID
	begin
		select top 1 @ChangeCursorID = id, @Src = Src, @Dst = Dst from #tempEnvChange where id > @ChangeCursorID order by id asc;

		set @TableMatchCheckFlag = 0
		select @TableMatchCheckSQL = concat( 'select @TableMatchCheckFlag = count(*) from ', @Tbl, ' where ', @Clm, ' like ''%', @Src, '%''' );
		EXEC sp_executesql @Query = @TableMatchCheckSQL, @Params = N'@TableMatchCheckFlag INT OUTPUT', @TableMatchCheckFlag = @TableMatchCheckFlag OUTPUT;

		if @TableMatchCheckFlag > 0 
		begin
			if @Dst is null
				begin
					--insert into #tempEnvActions
					--	select concat( '--i-- Removing "', @Src, '" from ', @Tbl, ' column ', @Clm ) as 'Action';
					insert into #tempEnvActions
						select concat( '--d-- select ''Delete from ', @Tbl, ' column ', @Clm, ''' as Action, ', @Clm, ' as Src from ', @Tbl, ' where ', @Clm, ' like ''%', @src, '%'';' ) as 'Action';
					insert into #tempEnvActions
						select concat( '--a-- delete from ', @Tbl, ' where ', @Clm, ' like ''%', @src, '%'';' ) as 'Action';
				end
			else
				begin
					--insert into #tempEnvActions
					--	select concat( '--i-- Replacing "', @Src, '" with "', @Dst, '" in table ', @Tbl, ' column ', @Clm ) as 'Action';
					insert into #tempEnvActions
						select concat( '--d-- select ''Replace in ', @Tbl, ' column ', @Clm, ''' as Action, ', @Clm, ' as Src, REPLACE(', @Clm, ', ''', @Src, ''', ''', @Dst, ''') as Dst from ', @Tbl, ' where ', @Clm, ' like ''%', @Src, '%'';' ) as 'Action';
					insert into #tempEnvActions
						select concat( '--a-- update ', @Tbl, ' set ', @Clm, ' = REPLACE(', @Clm, ', ''', @Src, ''', ''', @Dst, ''') where ', @Clm, ' like ''%', @Src, '%'';' ) as 'Action';
				end
		end
	end

end

select * from #tempEnvActions;