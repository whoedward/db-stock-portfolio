delete from portfolio_stock_portfolio;
delete from portfolio_portfolio;
delete from portfolio_users;
delete from portfolio_stock_symbols;

commit;

drop table portfolio_stock_portfolio;
drop table portfolio_portfolio;
drop table portfolio_users;
drop table portfolio_stock_symbols;
