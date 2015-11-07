#!/usr/bin/perl -w

use strict;




use CGI qw(:standard);
use URI::Escape;
use Switch;
use Scalar::Util;


use DBI;

use Time::ParseDate;


my $action;
my $run;

if (defined (param("act"))) {
  $action=param("act");
} else {
  $action="reg";
}

print header(-expires=>'now');
print "<html>";
print "<head>";
print "</head>";
print "<body>";


#everything starts here

print $action;

#base page is login/registration

if ($action eq "reg"){
  print "You gon b logged in son";

  #put a form here for separately loggin and registering
}

if ($action eq "portfolios") {
  print "Look at all this money you don't have";
}

if ($action eq "portfolio") {
  print "HAWT COFFEE TO THE FACE";
}



print "</body>";

print "</html>";
