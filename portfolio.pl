#!/usr/bin/perl -w
use strict;

use CGI qw(:standard);
use URI::Escape;
use Switch;
use Scalar::Util;

use DBI;

use Time::ParseDate;
my $debug=0; # default - will be overriden by a form parameter or cookie
my @sqlinput=();
my @sqloutput=();
use stock_data_access;
my $dbu = "gml654";
my $dbp = "zgfUP58ol";

my $action;
my $run;

my $user = undef;
my $password = undef;

my $cookiename="portfolio_session";
my $deletecookie;

my $inputcookiecontent = cookie($cookiename);
my $outputcookiecontent = undef;
my $logincomplain;

if (defined (param("act"))) {
  $action=param("act");
} else {
  $action="register";
}

if (defined (param("run"))){
  $run = param("run");
} else {
  $run = 0;
}

if ( defined ($inputcookiecontent)){
  ($user, $password) = split(/\//, $inputcookiecontent);
  $outputcookiecontent = $inputcookiecontent; 
}else{
  ($user, $password) = ("invalid", "invalid");   
}

if ($action eq "logout"){
  $deletecookie=1;
  $action = "login";
  $user = "invalid";
  $password = "invalid";
  $run = 1;
}

if ($action eq "login"){
  if($run){
    $user = param('user');
    $password = param('password');

    if(ValidUser($user,$password)){
      $outputcookiecontent=join("/",$user,$password);
      $action = "view-portfolios";
      $run = 1;
    } else {
      #have user attempt to login again
      $logincomplain = 1;
      $action = "login";
      $run = 0;
    }

  } else {
    undef $inputcookiecontent;
    $user = "invalid";
    $password = "invalid";
  }
}

my @outputcookies;

if (defined($outputcookiecontent)) {
  my $cookie = cookie(-name=>$cookiename,
                      -value=>$outputcookiecontent);
  push @outputcookies, $cookie;
}

print header(-expires=>'now', -cookie=>\@outputcookies);
print "<html>";
print "<head>";
print "</head>";
print "<body>";


#everything starts here

print "Begin generic debug info:<br>";
print "============================================================================================<br>";
print "act = $action;<br>";
print "Your cookie is $inputcookiecontent<br>", "Current username: $user<br>", "Current password: $password<br>";
print "End debug info<br>";
print "============================================================================================<br>";
print "<br><br><br>";

#base page is login/registration

if ($action eq "login"){
  if($logincomplain){
    print "login failed.  Please try again.";
  }
  if($logincomplain or !$run){
    print start_form(-name=>'Login'),
      h2('Login to your portfolio'),
    "Name:",textfield(-name=>'user'),   p,
      "Password:",password_field(-name=>'password'),p,
        hidden(-name=>'act',default=>['login']),
          hidden(-name=>'run',default=>['1']),
        submit,
          end_form;
  }
  if($run){
    print "Successful login'\'n";
    #TODO: check if valid user
  }
}

if ($action eq "register"){
  print "Register to start making portfolios<br>\n";
  if(!$run){
    #print form
    print start_form(-name=>'Register'),
    h2('Create an account'),
    "Name:",textfield(-name=>'user'), p,
    "Password:",password_field(-name=>'password'),p,
    hidden(-name=>'act',default=>['register']),
    hidden(-name=>'run',default=>['1']),
    submit,
    end_form;
  } else {
    #do sql stuff
    print "<br><br>\n";
    my $registername = param('user');
    my $registerpass = param('password');

    print "You chose the name $registername and password $registerpass\n";

    my @insertUser;
    my @insertPortfolio;
    eval {
      @insertUser = ExecSQL($dbu, $dbp, 'INSERT INTO portfolio_users (name, password) VALUES (? , ?)', undef, $registername, $registerpass);
      @insertPortfolio = ExecSQL($dbu, $dbp, "INSERT INTO portfolio_portfolio (id,owner,balance) VALUES (1,\'$registername\',0)");
   };

    if ($@) {
      print "Insert user error! Please try again with a different name and password.<br>\n";
      print $@;
    }else{
      print "User successfuly registered as $registername. Password is $registerpass<br>";
      print "<a href=\'http://murphy.wot.eecs.northwestern.edu/~gml654/db-stock-portfolio/portfolio.pl?act=login\'>Please login here now</a>";
    }
  }
}


#OUTDATED DELETE THIS ACTIONA
if ($action eq "getmoney"){
  if(!$run){

    print "TODO: have this dynamically get the users balances of each portfolio instead.";

    print start_form(-name>'Getmoney'),
    h2('Put money in box'),
    "Money:",textfield(-name=>'money'),p
    hidden(-name=>'act',default=>['getmoney']),
    hidden(-name=>'run',default=>['1']),
    submit,
    end_form;

    print $user;
  } else {
    my $money = param("money");

    print "Going to give you $money money";

    my @insertmoney;

    eval {
      @insertmoney = ExecSQL($dbu, $dbp, "UPDATE portfolio_users SET balance = balance + ? WHERE name =?", undef, $money, $user);
    };

    if($@) {
      print "Error: could not insert money";
      print $@;
    } else {
      print "Inserted $money dollars";
    }
  }
}

if ($action eq "sell-stock") {
  if(!$run){
    #maybe print out a list of users stocks and how many of each they own
    print "Sell a stock.  Enter a symbol from the list of stocks that you currently own and indicate how many you want to sell."; 
    print start_form, end_form;
  } else {

  }
}


if ($action eq "add-stock") {
  if(!$run){
    my $portfolioID = param("portfolio");
     print "Your current balance is:<br>";
  my @getBalance;
  my $bal;
  eval{
    @getBalance = ExecSQL($dbu, $dbp, "select balance from portfolio_portfolio where owner = \'$user\' and id = $portfolioID");
  };
  foreach $a (@getBalance){
     $bal = @$a;
     print @$a,"<br>";
  } 
   print "<br>";
    my @output = `./quote.pl AAPL`;
   print @output,"<br>";
   my $str= $output[5];
   $str =~ s/[^.\d]//g;
   print $str;
    print "<br>";
  $bal = $getBalance[0][0];
  print $bal;

  print $@; 
  print "<br>";
  
  print "test form here";


  my @output = `./quote.pl APPL`;
  print @output,"<br>";
  my $str= @output[5];
  $str =~ s/[^.\d]//g;
  print $str;
  print "<br>";
 
    print start_form(-name>'add-stock'),
    h2('Add/Sell a stock'),
    "Stock SYMBL: NOTE stock symbl must exist and must be capitalized",textfield(-name=>'name'),p
    "# of shares (postive to buy/negative to sell):",textfield(-name=>'shares'),p
    hidden(-name=>'act',default=>['add-stock']),
    hidden(-name=>'portfolio',default=>[$portfolioID]),
    hidden(-name=>'balance',default=>[$bal]),
    hidden(-name=>'run',default=>['1']),
    submit,
   end_form;

   }else{    
    my @output = `./quote.pl APPL`;
   my $str= @output[5];
   $str =~ s/[^.\d]//g;
    print "<br>, PRICE: ", $str;
  }else{
    my $symbl = param("name");
    my $shares = param("shares");
    my $portfolioID = param("portfolio");
    my $bal = param("balance");

    print "Portfolio ID: ",$portfolioID,"<br>";
    print "Symbol: ", $symbl, "<br> # of shares: ", $shares,"<br>";
    print $bal; 
    my @quote = `./quote.pl $symbl`;
    print "<br><br>";
    my $sharePrice = $quote[5];
    $sharePrice =~ s/[^.\d]//g;
    print "share price:", $sharePrice;

    my @subBalance;
    my $totalCost = $shares * $sharePrice;

    #first figure out if the user can buy this much
    if(defined $bal and ($bal > $totalCost)){
      #then figure out if the user already has the stock holding entry
      my @shares;

      eval {
        @shares = ExecSQL($dbu,$dbp,"select * from portfolio_stock_holding where owner=? and stock=? and portfolio_id=?", undef, $user, $symbl, $portfolioID);
      };
      
      if ($shares[0]){
        #it exists
        my @addShares;

        eval {
          @addShares = ExecSQL($dbu,$dbp,"UPDATE portfolio_stock_holding SET shares = shares + ? WHERE owner = ? and portfolio_id = ? and stock = ?",undef,$shares,$user,$portfolioID,$symbl);
        };
      } else {
        #it doesnt
        my @addHolding;
        
        eval {
          @addHolding = ExecSQL($dbu,$dbp,"INSERT into portfolio_stock_holding (owner,stock,shares,portfolio_id) VALUES (?,?,?,?)", undef, $user, $symbl,$shares,$portfolioID);
        };
        
        print "Added $shares shares of $symbl";
        print "Removed $totalCost from balance";
      }

      my @subtractBalance;
      
      eval {
        @subtractBalance = ExecSQL($dbu,$dbp,"UPDATE portfolio_portfolio SET balance = balance - ? WHERE owner = ? and id = ?", undef,$totalCost, $user,$portfolioID);
      };

      print $@;
    } else {
      print "You don't have enough money to buy $sharePrice worth of shares";
    }
  }
}

if ($action eq "view-portfolios") {
  print "Your portfolios:<br>";
  my @portfolios;
  eval {
       @portfolios = ExecSQL($dbu, $dbp, "SELECT id from portfolio_portfolio where owner = \'$user\'");
  };
  foreach $a (@portfolios){
     print "<a href = \'http://murphy.wot.eecs.northwestern.edu/~gml654/db-stock-portfolio/portfolio.pl?act=view-portfolio&portfolio=@$a\'>Portfolio #@$a</a><br>";
  }
  print "<a href=\'http://murphy.wot.eecs.northwestern.edu/~gml654/db-stock-portfolio/portfolio.pl?act=add-portfolio\'>Click to add a new portfolio</a>";
}

if ($action eq "add-portfolio") {
  my @addPortfolio;
  eval{
    @addPortfolio = ExecSQL($dbu, $dbp, "INSERT INTO portfolio_portfolio (id, owner, balance) values ((SELECT 1+max(id) from portfolio_portfolio where owner = \'$user\'), \'$user\',0)");  
  };
  if($@){
    print "cant insert<br>";
    print $@;
  }else{
    print "succesfully added new portfolio";
  }
}

if ($action eq "view-portfolio") {
  my $whichportfolio = param('portfolio');
  
  print "<h3>Portfolio ID: ",$whichportfolio,"</h3><br>";
  my @getBalance;
  my @getStocks;
  eval{
    @getStocks= ExecSQL($dbu,$dbp,"select stock from portfolio_stock_holding where owner = \'$user\' and portfolio_id = $whichportfolio");
    @getBalance = ExecSQL($dbu, $dbp, "select balance from portfolio_portfolio where owner = \'$user\' and id = $whichportfolio");
  }; 
  print "<h5>Your stocks:</h5>";
  foreach $a (@getStocks){
     print @$a,"<br>";
  }
  print "<a href = \'http://murphy.wot.eecs.northwestern.edu/~gml654/db-stock-portfolio/portfolio.pl?act=add-stock&portfolio=$whichportfolio\'>Add Stock</a><br><br>";
  #first we get each stock symbol in the portfolio
  
  print "Your current balance is:<br>";
  foreach $a (@getBalance){
     print @$a,"<br>";
  }
  print "<a href = \'http://murphy.wot.eecs.northwestern.edu/~gml654/db-stock-portfolio/portfolio.pl?act=add-balance&portfolio=$whichportfolio\'>Add balance</a><br>";
  
  print "<br>Making a covar matrix for your stocks <br> ====================== <br>";
}

if ($action eq "add-balance"){
   if (!$run){
    my $whichportfolio = param('portfolio');
   
    print "Your current balance is:<br>";
  my @getBalance;
  eval{
    @getBalance = ExecSQL($dbu, $dbp, "select balance from portfolio_portfolio where owner = \'$user\' and id = $whichportfolio");
  };
  foreach $a (@getBalance){
     print @$a,"<br>";
  } 

   print start_form(-name=>'add-balance'),
    h2('Insert positive money to deposit OR insert negative money to withdraw from portfolioID:', $whichportfolio),
    "Balance:",textfield(-name=>'balance'),p
    hidden(-name=>'act',default=>['add-balance']),
    hidden(-name=>'run',default=>['1']),
    hidden(-name=>'portfolio',default=>[$whichportfolio]),
    submit,
    end_form;
  }else{
   my $balance = param('balance');
   my $whichportfolio = param('portfolio');
   my @insertBalance;
   eval{
     @insertBalance = ExecSQL($dbu, $dbp, "update portfolio_portfolio set balance = balance + $balance where id = $whichportfolio and owner = \'$user\'");
   };
    
   if($@){
     print "error inserting balance<br>";
     print $@;
   }else{
     print "succesfully updated balance<br>";

   }

  } 
}




if ($action eq "portfolio-balance") {

  my $whichportfolio = param('portfolio');

  if (!$run){
    print start_form(-name=>'portfolio-balance'),
    h2('Insert how much money you want for portfolio ID: $whichportfolio'),
    "Money:",textfield(-name=>'money'),p
    hidden(-name=>'act',default=>['portfolio-balance']),
    hidden(-name=>'run',default=>['1']),
    hidden(-name=>'portfolio',default=>[$whichportfolio]),
    submit,
    end_form;
  }
}



print "</body>";

print "</html>";

sub displayPortfolio{
  my($user,$portfolioID,$balance,$symbl,$shares)=@_;
  my @getStocksShares;
  my @output = `./quote.pl AAPL`;
   print @output,"<br>";
   my $str= $output[5];
   $str =~ s/[^.\d]//g;
   print $str;
    print "<br>";
 
 eval {
    @getStocksShares= ExecSQL($dbu,$dbp,"select stock,shares from portfolio_stock_holding where owner = \'$user\' and portfolio_id = $portfolioID");
  };
  print "==displayPort==", @getStocksShares;
}

sub ValidUser{
  my($user,$pass)=@_;
  
  my @check;

  eval {
    @check = ExecSQL($dbu,$dbp,'select * from portfolio_users where name =? AND password =?', undef, $user, $pass);
  };

  if ($@){
    return 0;
  } else {
    if ($check[0][0]){
      return 1;
    } else {
      return 0;
    }
  }
}

#
# Given a list of scalars, or a list of references to lists, generates
# an html table
#
#
# $type = undef || 2D => @list is list of references to row lists
# $type = ROW   => @list is a row
# $type = COL   => @list is a column
#
# $headerlistref points to a list of header columns
#
#
# $html = MakeTable($id, $type, $headerlistref,@list);
#
sub MakeTable {
  my ($id,$type,$headerlistref,@list)=@_;
  my $out;
  #
  # Check to see if there is anything to output
  #
  if ((defined $headerlistref) || ($#list>=0)) {
    # if there is, begin a table
    #
    $out="<table id=\"$id\" border>";
    #
    # if there is a header list, then output it in bold
    #
    if (defined $headerlistref) { 
      $out.="<tr>".join("",(map {"<td><b>$_</b></td>"} @{$headerlistref}))."</tr>";
    }
    #
    # If it's a single row, just output it in an obvious way
    #
    if ($type eq "ROW") { 
      #
      # map {code} @list means "apply this code to every member of the list
      # and return the modified list.  $_ is the current list member
      #
      $out.="<tr>".(map {defined($_) ? "<td>$_</td>" : "<td>(null)</td>" } @list)."</tr>";
    } elsif ($type eq "COL") { 
      #
      # ditto for a single column
      #
      $out.=join("",map {defined($_) ? "<tr><td>$_</td></tr>" : "<tr><td>(null)</td></tr>"} @list);
    } else { 
      #
      # For a 2D table, it's a bit more complicated...
      #
      $out.= join("",map {"<tr>$_</tr>"} (map {join("",map {defined($_) ? "<td>$_</td>" : "<td>(null)</td>"} @{$_})} @list));
    }
    $out.="</table>";
  } else {
    # if no header row or list, then just say none.
    $out.="(none)";
  }
  return $out;
}


#
## @list=ExecSQL($user, $password, $querystring, $type, @fill);
##
## Executes a SQL statement.  If $type is "ROW", returns first row in list
## if $type is "COL" returns first column.  Otherwise, returns
## the whole result table as a list of references to row lists.
## @fill are the fillers for positional parameters in $querystring
##
## ExecSQL executes "die" on failure.
##

sub ExecSQL {
  my ($user, $passwd, $querystring, $type, @fill) =@_;
  if ($debug) { 
    # if we are recording inputs, just push the query string and fill list onto the 
    # global sqlinput list
    push @sqlinput, "$querystring (".join(",",map {"'$_'"} @fill).")";
  }
  my $dbh = DBI->connect("DBI:Oracle:",$user,$passwd);
  if (not $dbh) { 
    # if the connect failed, record the reason to the sqloutput list (if set)
    # and then die.
    if ($debug) { 
      push @sqloutput, "<b>ERROR: Can't connect to the database because of ".$DBI::errstr."</b>";
    }
    die "Can't connect to database because of ".$DBI::errstr;
  }
  my $sth = $dbh->prepare($querystring);
  if (not $sth) { 
    #
    # If prepare failed, then record reason to sqloutput and then die
    #
    if ($debug) { 
      push @sqloutput, "<b>ERROR: Can't prepare '$querystring' because of ".$DBI::errstr."</b>";
    }
    my $errstr="Can't prepare $querystring because of ".$DBI::errstr;
    $dbh->disconnect();
    die $errstr;
  }
  if (not $sth->execute(@fill)) { 
    #
    # if exec failed, record to sqlout and die.
    if ($debug) { 
      push @sqloutput, "<b>ERROR: Can't execute '$querystring' with fill (".join(",",map {"'$_'"} @fill).") because of ".$DBI::errstr."</b>";
    }
    my $errstr="Can't execute $querystring with fill (".join(",",map {"'$_'"} @fill).") because of ".$DBI::errstr;
    $dbh->disconnect();
    die $errstr;
  }
  #
  # The rest assumes that the data will be forthcoming.
  #
  #
  my @data;
  if (defined $type and $type eq "ROW") { 
    @data=$sth->fetchrow_array();
    $sth->finish();
    if ($debug) {push @sqloutput, MakeTable("debug_sqloutput","ROW",undef,@data);}
    $dbh->disconnect();
    return @data;
  }
  my @ret;
  while (@data=$sth->fetchrow_array()) {
    push @ret, [@data];
  }
  if (defined $type and $type eq "COL") { 
    @data = map {$_->[0]} @ret;
    $sth->finish();
    if ($debug) {push @sqloutput, MakeTable("debug_sqloutput","COL",undef,@data);}
    $dbh->disconnect();
    return @data;
  }
  $sth->finish();
  if ($debug) {push @sqloutput, MakeTable("debug_sql_output","2D",undef,@ret);}
  $dbh->disconnect();
  return @ret;
}


# The following is necessary so that DBD::Oracle can
# find its butt
#
BEGIN {
  $ENV{PORTF_DBMS}="oracle";
  $ENV{PORTF_DB}="cs339";
  $ENV{PORTF_DBUSER}="gml654";
  $ENV{PORTF_DBPASS}="zgfUP58ol";
  $ENV{PATH}=$ENV{PATH}.":.";
  unless ($ENV{BEGIN_BLOCK}) {
    use Cwd;
    $ENV{ORACLE_BASE}="/raid/oracle11g/app/oracle/product/11.2.0.1.0";
    $ENV{ORACLE_HOME}=$ENV{ORACLE_BASE}."/db_1";
    $ENV{ORACLE_SID}="CS339";
    $ENV{LD_LIBRARY_PATH}=$ENV{ORACLE_HOME}."/lib";
    $ENV{BEGIN_BLOCK} = 1;
    exec 'env',cwd().'/'.$0,@ARGV;
  }
}

