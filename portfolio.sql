create table portfolio_users (
  name varchar(64) not null primary key,
  password varchar(64) not null
);
create table portfolio_portfolio(
  id number not null, 
  owner varchar(64) not null references portfolio_users(name),
  constraint portfolio_pk primary key (id, owner),
  balance number not null
);
create table portfolio_stock_symbols(
  name varchar(16) unique not null
);
create table portfolio_stock_portfolio(
  owner varchar(64) not null references portfolio_users(name),
--TODO: find out how long stock key can be
  stock varchar(16) not null references portfolio_stock_symbols(name),
  owned number not null,
  constraint name unique (owner, stock)
);

INSERT all into portfolio_stock_symbols(name) SELECT unique symbol FROM cs339.StocksDaily;
--INSERT into portfolio_users (name, password, balance) VALUES ('anon', 'anonanon', 0);
--Test users--
INSERT into portfolio_users (name, password) VALUES ('poorjoe','poorjoe');
INSERT into portfolio_portfolio (id, owner, balance) VALUES (1, 'poorjoe', 0);

INSERT into portfolio_users (name, password) VALUES ('bigshot', 'bigshoot');
INSERT into portfolio_portfolio (id, owner, balance) VALUES (1, 'bigshot',0);
