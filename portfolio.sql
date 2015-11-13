create table portfolio_users (
  name varchar(64) not null primary key,
  password varchar(64) not null,
  constraint long_password CHECK (password LIKE '______%')
);
create table portfolio_portfolio(
  id number not null, 
  owner varchar(64) not null references portfolio_users(name),
  constraint portfolio_pk primary key (id, owner),
  balance number not null,
  constraint balance_positive CHECK (balance >= 0)
);
--we create a table to represent all the UNIQUE stock symbols
create table portfolio_stock_symbols(
  symbol varchar (16) not null unique
);
--then we take every stock symbol and insert it in
INSERT into portfolio_stock_symbols (symbol) select unique symbol from cs339.StocksDaily; 
--This table represents the ownership relation of a stock owner
create table portfolio_stock_holding(
  owner varchar(64) not null,
  portfolio_id number not null,
  foreign key (owner, portfolio_id) references portfolio_portfolio(owner, id),
--TODO: find out how long stock key can be
  stock varchar(16) not null references portfolio_stock_symbols(symbol),
  shares number not null,
  primary key (owner,portfolio_id,stock)
);

--INSERT into portfolio_users (name, password, balance) VALUES ('anon', 'anonanon', 0);
--Test users--
INSERT into portfolio_users (name, password) VALUES ('poorjoe','poorjoe');
INSERT into portfolio_portfolio (id, owner, balance) VALUES (1, 'poorjoe', 0);

INSERT into portfolio_users (name, password) VALUES ('bigshot', 'bigshot');
INSERT into portfolio_portfolio (id, owner, balance) VALUES (1, 'bigshot', 50000);

