#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
cd $MYDIR &&
branch=$(git branch | sed -n 's/^* //p') &&
[ "$branch" == "master" ] &&
contents=$(pod2markdown wrapperl | kramdown) &&
git checkout gh-pages &&
(
   cat html.preamble
   echo "$contents"
   cat html.postamble  
)> index.html &&
(
   git commit index.html -m 'aligned documentation'
   git checkout master
)
