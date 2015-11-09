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
  ($user, $password) = ("anon", "anonanon");   
}

if ($action eq "logout"){
  $deletecookie=1;
  $action = "login";
  $user = "anon";
  $password = "anonanon";
  $run = 1;
}

if ($action eq "login"){
  if($run){
    $user = param('user');
    $password = param('password');

    if(ValidUser($user,$password)){
      $outputcookiecontent=join("/",$user,$password);
      $action = "base";
      $run = 1;
    } else {
      #have user attempt to login again
      $logincomplain = 1;
      $action = "login";
      $run = 0;
    }

  } else {
    undef $inputcookiecontent;
    $user = "anon";
    $password = "anonanon";
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

print $action;
print "Ur cookie is $inputcookiecontent and ur username is $user and ur password is $password.<br>";


#base page is login/registration

if ($action eq "register"){
  print "You gon b logged in son";

  #put a form here for separately loggin and registering
}

if ($action eq "login"){
  if($logincomplain){
    print "login failed.  plz try again lol.";
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
}

if ($action eq "register"){
  if(!$run){
    #print form
    print start_form(-name=>'Register'),
    h2('Gib us ur mony'),
    "Name:",textfield(-name=>'user'), p,
    "Password:",password_field(-name=>'password'),p,
    hidden(-name=>'act',default=>['register']),
    hidden(-name=>'run',default=>['1']),
    submit,
    end_form;
  } else {
    #do sql stuff
    print "you just got registed son";
    my $registername = param('user');
    my $registerpass = param('password');

    print "u chose the name $registername and password $registerpass";

    my @insertUser;

    eval {
      @insertUser = ExecSQL($dbu, $dbp, 'INSERT INTO portfolio_users (name, password, balance) VALUES (? , ?, 0)', undef, $registername, $registerpass);
    };

    if ($@) {
      print "Insert user error!";
    }
  }
}

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

if ($action eq "create-portfolio") {
    print "Creating portfolio";
}

if ($action eq "portfolio-balance") {
    print "Giving u le money";
}

if ($action eq "portfolios") {
  print "Look at all this money you don't have";
}

if ($action eq "portfolio") {
  print "HAWT COFFEE TO THE FACE";
}



print "</body>";

print "</html>";



sub ValidUser{
  return 1;
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

