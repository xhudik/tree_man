# tree_man
###### Please note: this is only a use case. Currently not working!

## Summary
The solution is implemented in MongoDB and PERL. We followed [tree structure with children references](https://docs.mongodb.com/manual/tutorial/model-tree-structures-with-child-references/),
since is it should be slightly faster than standard [tree with parent reference] (https://docs.mongodb.com/manual/tutorial/model-tree-structures-with-parent-references/) and still relatively easy to implement. Currently, we are having problem with adding new nodes.

## Requirements
The task was to write a web based application that allows a user to view an existing, initially empty, tree and add nodes to it.Tree nodes should be stored in the MySQL database. 
Thus, the program should be able to read them from the database to display the tree, and add new nodes to the tree upon a user request.  Further, code should easily re-usable there should be thinking out of the box and trying to "over engineer".

## Solution
Since standard relational DBs, like MySQL,  have problems with managing hierarchical data (e.g. [description](]http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/), 
or [here](http://stackoverflow.com/questions/5916482/php-mysql-best-tree-structure), we tried to look for a better solution.  [Mongo](https://www.mongodb.com/) as document-oriented database
seems to be a good candidate to give a try: (https://docs.mongodb.com/manual/applications/data-models-tree-structures/). We have decided to give a try to a bit old-fashioned :) but pretty 
stable and well-documented [Perl](https://www.perl.org/) 

### Initial steps
1. Install MongoDB, on Debian: `aptitude install mongodb mongodb-clients`
2. Install Perl driver for MongoDB, on Debian only an old version is avaiable, therfore it is better to compile on your own: `cpan Config::AutoConf Path::Tiny MongoDB`;
[more info](https://github.com/mongodb/mongo-perl-driver/blob/master/INSTALL.md)
3. Install apache and mod_perl, on Debian: `aptitude install apache2 libapache2-mod-perl2`
4. Run MongoDB (as root): `mongod --dbpath mongodb/`, where  `mongodb/` is an empty dir
5. Run apache  `/etc/init.d/apache2 restart`
6. For debugging purposes we have developed an initial tree in MongoDB, run MongoDB (as a normal user) and issue the following commands
```bash
use trees
db.node.insert({ _id:1,children: [2,3] })
db.node.insert({ _id:2,children: [5,6,8] })
db.node.insert({ _id:3,children: [4] })
db.node.insert({ _id:4,children: [9] })
db.node.insert({ _id:5,children: [] })
db.node.insert({ _id:6,children: [] })
db.node.insert({ _id:8,children: [] })
db.node.insert({ _id:9,children: [] })
```
7. clone this project `git clone https://github.com/xhudik/tree_man` and copy scripts from cgi-bin to your Apache implementation

### Status
Due to time constraints, the project has not been finished yet. Tree is printed out correctly (recursion function used). Adding new nodes doesnt work. 
The problem is in these lines:
```perl
 my $add = $all_nodes->update_one({'_id' => $PID}, {'$push' => {'children' => $new_node }});
 my $new = $all_nodes->insert_one( { '_id' => $new_node, 'children' => [] } );
```
Where we are trying to push a new child ID into parent' node and create a new node. While these lines are working if they are placed in main program `tree_manager.pl`, they do not work
and do not produce any errors if they are in `add.pl`
