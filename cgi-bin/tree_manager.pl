#!/usr/bin/perl -w
use strict;
use warnings;
#redirect errors to webbrowser - switch off!!!
use CGI::Carp qw(fatalsToBrowser warningsToBrowser); 
use MongoDB;
use Data::Dumper;
use Try::Tiny;
use Safe::Isa;


#INITIAL HTML PART
print "Content-type: text/html\n\n";
#be careful - remove all white spaces
print <<ENDHTML;
<html>
<head>
<title>Trees</title>
</head>
<body>
<h1>Tree Manager</h1>
<h3>Current tree:</h3>
<table border="1">
ENDHTML

#DB connection - 127.0.0.1 by default
my $client = MongoDB->connect();
#change DB
my $db = $client->get_database( 'trees' );
#pick collection
my $all_nodes = $db->get_collection( 'node' );


#if init tree with node ID=1 doesnt exists - create it
my $init_tree = $all_nodes->find_id(1);
if(! $init_tree){
  try {
  $all_nodes->insert_one( { '_id' => 1, 'children' => [] } );
 }
catch {warn "caught error: $_"; }
  }


####TH DEBUGGING START####
#my $tree = $all_nodes->find({ _id => 1 })
    #order by  
   # ->sort({ _id => 1 });
#my @matrix;
  
#print nodes
#while (my $node = $tree->next) {
  #node - how many children 
#  my $nchildren = @{$node->{children}};
  
#  my @row;
#  print("<tr><td>Node:".$node->{_id}." </td>");
 # foreach my $child (@{$node->{children}}){
 #   push(@row,$child);
 #   print("<td>$child</td>");
#  }
  
#   push(@matrix, \@row);
#  print("</tr>");
#}


#print("</table><br/><table  border='1'>");
#my $level = 1;
#foreach my $row1 (@matrix){
#  print("<tr><td>Level ".$level++."</td>");
#  #my @columns = @{$matrix[$row]};
#  foreach my $column (@$row1){
 # #foreach my $column (@columns){
#    print("<td>$column</td>");
#  }
#  print("</tr>");
#}
#print("</table><br/>");

####TH DEBUGGING END####

#printing tree
print("<table  border='1' style='width:100%'><tr><th>Depth</th><th>Tree nodes</th></tr>");
#highest ID
my $highest = 1;
my $depth = 0; 
my @pp=traverse(([1]));


#recursive function for printing out the tree
sub traverse{
  my @ids =@_;
  if($#ids < 0) {return}
  #print out current depth
  print("<tr><td>".$depth++."</td><td>");
  my @next;
  foreach my $row (@ids){
    print(" ");
    foreach my $id (@$row){
      print("[",$id."] ");
      if($id>$highest){
	$highest = $id;
	}
      my $res = $all_nodes->find({'_id' => $id });
      my @all = $res->all;
      #if node exists and has children - push the new node
      if((@all)&&(@{$all[0]->{children}}!=0)) {
	push(@next,$all[0]->{children});
      }
    }
    print("|");
  }  
  print("</td></tr>");
  traverse(@next);
}
print("</table>");

#count new node ID
my $new_node = $highest + 1;

#forms
print <<ENDHTML;
<form action="/cgi-bin/add.pl" method="get">
</br></br></br>
 Add node to:  <input type="text" name="PID" value="PID"><br>
 <input type="hidden" name="new_node" value=$new_node>
 <input type="submit" value="Submit">
</form>
ENDHTML



#FINISH HTML
print <<ENDHTML;
</body></html>
ENDHTML