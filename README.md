# tree_man
###### Please note: this is only a use case. 

## Summary
The solution is implemented in MongoDB and PERL. We followed [tree structure with children references](https://docs.mongodb.com/manual/tutorial/model-tree-structures-with-child-references/),
since it should be slightly faster than standard [tree with parent reference] (https://docs.mongodb.com/manual/tutorial/model-tree-structures-with-parent-references/) and still relatively easy to implement.

## Requirements
The task was to write a web based application that allows a user to view an existing, initially empty, tree and add nodes to it.Tree nodes should be stored in the MySQL database. 
Thus, the program should be able to read them from the database to display the tree, and add new nodes to the tree upon a user request.  Further, code should easily re-usable there should be thinking out of the box and trying to "over engineer".

## Solution
Since standard relational DBs, like MySQL,  have problems with managing hierarchical data (e.g. [description](]http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/), 
or [here](http://stackoverflow.com/questions/5916482/php-mysql-best-tree-structure), we tried to look for a better solution.  [Mongo](https://www.mongodb.com/) as document-oriented database
seems to be a good candidate to give a try: (https://docs.mongodb.com/manual/applications/data-models-tree-structures/). Then, we picked a bit old-fashioned :) but pretty stable and well-documented [Perl](https://www.perl.org/) as programming languge.

### Initial steps
1. Install MongoDB (version 2.4.10), on Debian: `aptitude install mongodb mongodb-clients`
2. Install Perl driver for MongoDB (version 1.4.2), on Debian only an old version is avaiable, therfore it is better to compile on your own: `cpan Config::AutoConf Path::Tiny MongoDB`;
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
Due to time constraints, some minor issues are still bothering. Tree is printed out correctly (recursion 
function used). However, it should be printed better (e.g. with info about parents ID). Anyway, these 
problems are mainly engineerings and no additional research is necessary. In case of printing parents ID - 
we need to change arry to hash in the recursive function `traverse`
#### Further possible improvements
* Printing parent ID
* Better UI
* Optiomization and security (new ID should be counted in `add.pl` instead of current `tree_manager.pl`
* Catch exceptions and think about possible errors
