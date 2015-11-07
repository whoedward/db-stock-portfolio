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
}

print header(-expires=>'now');
print "<html>";
print "<head>";
print "</head>";
print "<body>";


#everything starts here

print $action;











print "</body>";

print "</html>";
