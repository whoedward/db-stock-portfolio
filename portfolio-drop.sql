delete from portfolio_stock_holding;
delete from portfolio_portfolio;
delete from portfolio_users;

commit;

drop table portfolio_stock_holding;
drop table portfolio_portfolio;
drop table portfolio_users;
