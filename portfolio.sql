create table portfolio_users (
  name varchar(64) not null primary key,
  password varchar(64) not null,
  balance number not null
);
create table portfolio_portfolio(
  id number not null, 
  owner varchar(64) not null references portfolio_users(name),
  constraint portfolio_pk primary key (id, owner),
  balance number not null
);
create table portfolio_stock_portfolio(
  owner varchar(64) not null references portfolio_users(name),
--TODO: find out how long stock key can be
  stock varchar(16) not null,
  owned number not null,
  constraint name unique (owner, stock)
);

--INSERT into portfolio_users (name, password, balance) VALUES ('anon', 'anonanon', 0);
