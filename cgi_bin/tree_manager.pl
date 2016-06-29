#!/usr/bin/perl -w
use strict;
use warnings;
#redirect errors to webbrowser - switch off!!!
use CGI::Carp 'fatalsToBrowser';
use MongoDB;
use Data::Dumper;


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

my $tree = $all_nodes->find()
    #order by  
    ->sort({ _id => 1 });

my @matrix;

  #pokus DELETEEE
  #my $add= $all_nodes->update_one({"_id" => 9}, {'$push' => {'children' => 10 }});
  #my $new = $all_nodes->insert_one( { _id => 13, children => [50,100] } );
  #print("<h3> new---$new");
  #ENDDD

#print tree
while (my $node = $tree->next) {
  #node - how many children 
  my $nchildren = @{$node->{children}};
  
  my @row;
  print("<tr><td>Node:".$node->{_id}." </td>");
  foreach my $child (@{$node->{children}}){
    push(@row,$child);
    print("<td>$child</td>");
  }
  
#print("_id=".$node->{ '_id' }.";; children=".$children[0][0].";;;ref=".ref($node->{children}));
#print("AA children=".$node->{children}.";;;ref=".ref($node->{children}));
#print("node->children=".$node->{children}.";".@{$node->{children}}.";;size=".@{$node->{children}}.";1.st elem".$node->{children}[0]);

#print("[pid=".$node{'pid'}.";id=".$node{'id'}.']');
    #while(my ($k,$v)=each $node)
#	{print "$k => $v ;;"
#	}
   push(@matrix, \@row);
  print("</tr>");
}


print("</table><br/><table  border='1'>");
my $level = 1;
foreach my $row1 (@matrix){
  print("<tr><td>Level ".$level++."</td>");
  #my @columns = @{$matrix[$row]};
  foreach my $column (@$row1){
  #foreach my $column (@columns){
    print("<td>$column</td>");
  }
  print("</tr>");
}
print("</table><br/>");


#creating levels
print("<table  border='1' style='width:100%'>");
#highest ID
my $highest = 1;
my @pp=traverse(([1]));


#recursive function for printing out the tree
sub traverse{
  my @ids =@_;
  if($#ids < 0) {return}
  #print out current depth
  print("<tr>");
  my @next;
  foreach my $row (@ids){
    print(" <td>");
    foreach my $id (@$row){
      print("[",$id."] ");
      if($id>$highest){
	$highest = $id;
	}
      my $res = $all_nodes->find({'_id' => $id });
      my @all = $res->all;
      #if node exists and has children - push them
      if((@all)&&(@{$all[0]->{children}}!=0)) {
	push(@next,$all[0]->{children});
      }
    }
    print("</td>");
  }  
  print("</tr>");
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
 <h3>$new_node==new</h3>
 <input type="hidden" name="new_node" value=$new_node>
 <input type="submit" value="Submit">
</form>
ENDHTML



#FINISH HTML
print <<ENDHTML;
</body></html>
ENDHTML