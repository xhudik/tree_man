#!/usr/bin/perl -w
use strict;
use warnings;
#redirect errors to webbrowser - switch off!!!
use CGI::Carp 'fatalsToBrowser';
use MongoDB;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use Try::Tiny;
use Safe::Isa;



#FORM PROCESSING
my ($buffer, @pairs, $pair, $name, $value, %FORM);
# Read in text
$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "GET"){
  $buffer = $ENV{'QUERY_STRING'};
   }
   # Split information into name/value pairs
@pairs = split(/&/, $buffer);
foreach $pair (@pairs){
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%(..)/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  }   

my $PID = $FORM{PID};
my $new_node = $FORM{new_node};

#MAIN PROGRAM
#check the insterted number (PID)
if(looks_like_number($PID)){
  #DB connection - 127.0.0.1 by default
  my $client = MongoDB->connect();
  #change DB
  my $db = $client->get_database( 'trees' );
  #pick collection
  my $all_nodes = $db->get_collection( 'node' );
  my $res = $all_nodes->find({'_id' => $PID });
  my @all = $res->all;
try {
	#NOT WORKING - in main program thes two commands work fine!
  my $add = $all_nodes->update_one({'_id' => $PID}, {'$push' => {'children' => $new_node }});
  my $new = $all_nodes->insert_one( { '_id' => $new_node, 'children' => [] } );
 }
catch {warn "caught error: $_"; }

  #if PID exists in DB (as _id)
  #if($all[0]) {
  
    #if it has no children
     #if(@{$all[0]->{children}}!=0) {
	#$all_nodes->insert_one( {
   # "name" => "Joe",
    #"age" => 52,
    #"likes" => [qw/skiing math ponies/]
   # });
	#}else{
	#probably forest
	#print <<ENDHTML;
#<html>
#<head>
#<title>Trees</title>
#</head>
#<body>
#ENDHTML
  #    print("<h3>I dont have $PID  in DB. If you want forest - go out! <a href='http://127.0.0.1/cgi-bin/tree_manager.pl'>try again</a></h3></body></html> ");  	
	#}
  
}else{
#INITIAL HTML PART
print "Content-type: text/html\n\n";
#be careful - remove all white spaces
print <<ENDHTML;
<html>
<head>
<title>Trees</title>
</head>
<body>
ENDHTML
  print("<h3>There is some problem with your: $PID  - think about and <a href='http://127.0.0.1/cgi-bin/tree_manager.pl'>try again</a></h3></body></html> ");  
  exit(10)
}
    

#INITIAL HTML PART
print "Content-type: text/html\n\n";
#be careful - remove all white spaces
print <<ENDHTML;
<html>
<head>
<META HTTP-EQUIV=refresh CONTENT=\"1;URL=http://localhost/cgi-bin/tree_manager.pl\">
</head>
</html>
ENDHTML
