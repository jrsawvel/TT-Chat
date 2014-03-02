-- ttchat-messages.sql
-- 27-Feb-2014

-- drop table if exists ttchat_messages;
create table ttchat_messages (
    message_id        mediumint unsigned auto_increment primary key,
    message_text      mediumtext not null,
    message_status    char(1) not null default 'o',  -- (o) open for display, (d) deleted 
    author_id         smallint unsigned not null,
    author_name	      varchar(30) not null,
    created_date      datetime, 
    ip_address        varchar(30),
    index(message_id)
) ENGINE = MyISAM;

