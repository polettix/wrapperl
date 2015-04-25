#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
cd $MYDIR &&
[ -e 'wrapperl' ] &&
pod2markdown wrapperl README.md &&
contents=$(kramdown README.md) &&
here=$(git reflog | perl -nale 'print$F[0];last') &&
git checkout gh-pages &&
echo "$contents" > index.html &&
(
   git commit index.html -m 'aligned documentation'
   git checkout "$here"
)
