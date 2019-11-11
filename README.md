# ginger
easy to use git wrapper

Remembers all the git cryptic syntax so you don't have to.

(Currently only windows port is in development.)

## installation

Drop `ginger.bat` or `ginger` to your `$PATH`.

## commands

```
~ginger commands
  Display list of commands.
  
~ginger help [command]
  Display help (for command).

~ginger version
  Show version number etc.

~ginger init
  Invokes repository init wizard.
  
ginger login
  Set up credientals of this project.

ginger changed [path]
  Displays what changed since last commit.
  Used as diff when you provides [path].  

~ginger commit
  Let you commit a change.
  
ginger sweep
  Undo local changes to last commit.

~ginger pull
  Pulls changes from remote repository protecting your local files optionally.
  
~ginger push
  Pushes changes back to the server.
  
ginger spinoff
  Creates new branch.
  
~ginger orphan
  Creates new branch with no parent.  

ginger branches
  Display list of branches.

ginger switch <branch>
  Switches to <branch>.
  
ginger look
  Displays current repository, branch and user.
  
~ginger timeline <before/after/parents/childs> <ref>
  Displays history of commits.
  
~ means not yet implemented
```

## resources

* [tldr pages](https://tldr.ostera.io/git)
* [easy git (wrapper)](https://people.gnome.org/~newren/eg/)
* [giteveryday](https://www.kernel.org/pub/software/scm/git/docs/giteveryday.html)
* [Pro Git](https://progit.org) /  [česky](https://git-scm.com/book/cs/v1)
* [git ready](http://gitready.com)
* unversal command [git rev-parse](https://git-scm.com/docs/git-rev-parse)
* [Git as a NoSql database](https://www.kenneth-truyers.net/2016/10/13/git-nosql-database/)
* https://github.com/shobhitpuri/git-refresh
* https://stackoverflow.com/questions/1822849/what-are-these-ms-that-keep-showing-up-in-my-files-in-emacs
* http://think-like-a-git.net/
* http://tom.preston-werner.com/2009/05/19/the-git-parable.html
* https://githowto.com/
* https://ohshitgit.com/
* https://github.com/benharri/learngit
* https://github.com/jayphelps/git-blame-someone-else
* https://dzone.com/articles/top-20-git-commands-with-examples
