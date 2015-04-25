#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
cd $MYDIR &&
branch=$(git branch | sed -n 's/^* //p') &&
[ "$branch" == "master" ] &&
pod2markdown wrapperl README.md &&
git commit README.md -m 'aligned documentation' &&
contents=$(cat html.preamble README.md html.postamble) &&
git checkout gh-pages &&
echo "$contents" > index.html &&
(
   git commit index.html -m 'aligned documentation' &&
   git push
   git checkout master
)
