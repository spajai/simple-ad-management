create table if not exists ad_mgmt (
    code int not null auto_increment,
    Ad_owner varchar (50) null,
    Ad_Name varchar (50) null,
    Mobile   varchar (50) null,
    Transaction  varchar (50) null,
    Distribution  timestamp null default now(),
    last_modfied timestamp null default null on update now(),
    primary key (code)
)
engine=innodb
default charset=utf8
collate=utf8_general_ci;
create unique index tickets_id_idx using btree on ad_mgmt (code);