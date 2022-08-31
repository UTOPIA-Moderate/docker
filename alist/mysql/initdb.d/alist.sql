create user 'alist'@'%' identified by '1234qwer';

create database if not exists alist default charset utf8 collate utf8_general_ci;

grant all privileges on alist.* to alist@'%';
