# NAME

wrapperl - wrapper for Perl customized invocation

# TL;DR

... or an example is worth a whole manual sometimes.

Let's make a few assumptions:

- you will write your program `prg.pl`. If
you don't even want to write one, you can copy and paste this:

        #!/usr/bin/env perl
        print "using perl '$^X', \@INC contains:\n";
        print "- '$_'\n" for @INC;

- you do your coding in a development environment where:
    - you develop `prg.pl` inside directory `/home/me/program`
    - `perl` is located at `/home/me/perl/bin/perl`
    - the libraries are stored in non-standard positions
    `/path/to/some/lib` and `/path/to/another/lib`
- you deploy your program in a production environment with a different
setup, namely:
    - your program `prg.pl` is deployed in directory `/app/program`
    - `perl` is located at `/approved/perl/bin/perl`
    - the libraries you need are all stored in `/approved/lib`

In both environments, you create a symbolic link named `prg`
pointing towards `wrapperl` and located inside the same directory
as `prg.pl`.

Inside the same directory, or any ancestor, you create the
`wrapperl.env` file, which will be specific for the environment.
We will put the file in the same directory as `prg` and `prg.pl`
in this example.

This is what you end up with in the development environment:

    me@devhost /home/me/program$ ls -l
    lrwxrwxrwx 1 me me  8 Apr 23 22:51 prg -> /home/me/bin/wrapperl
    -rwxr-xr-x 1 me me 74 Apr 23 22:28 prg.pl
    -rwxr-xr-x 1 me me 74 Apr 22 12:35 wrapperl.env

    me@devhost /home/me/program$ cat wrapperl.env
    $ENV{PERL5LIB} = '/path/to/some/lib:/path/to/another/lib';
    $PERL = '/home/me/perl/bin/perl';

This is what you have in the production environment:

    me@production /app/program$ ls -l
    lrwxrwxrwx 1 me me  8 Apr 25 20:51 prg -> /usr/local/bin/wrapperl
    -rwxr-xr-x 1 me me 74 Apr 25 20:51 prg.pl
    -rwxr-xr-x 1 me me 74 Apr 25 20:51 wrapperl.env

    me@production /app/program$ cat wrapperl.env
    $ENV{PERL5LIB} = '/approved/lib';
    $PERL = '/approved/perl/bin/perl';

So yes, they two setups are mostly the same, except for the
`wrapperl.env` file contents that contain the environment-specific
configurations.

Now, you are ready to run your program in either environment, just
remember to execute the symbolic link to `wrapperl` instead of your
program.

In the development environment:

    me@devhost /home/me/program$ ./prg
    using perl '/home/me/perl/bin/perl', @INC contains:
    - '/path/to/another/lib/i686-linux'
    - '/path/to/another/lib'
    - '/path/to/some/lib/i686-linux'
    - '/path/to/some/lib'
    - '/home/me/perl/lib/site_perl/5.18.1/i686-linux'
    - '/home/me/perl/lib/site_perl/5.18.1'
    - '/home/me/perl/lib/5.18.1/i686-linux'
    - '/home/me/perl/lib/5.18.1'
    - '.'

In the production environment:

    me@production /app/program$ cat wrapperl.env
    using perl '/approved/perl/bin/perl', @INC contains:
    - '/approved/lib/i686-linux'
    - '/approved/lib'
    - '/approved/perl/lib/site_perl/5.18.1/i686-linux'
    - '/approved/perl/lib/site_perl/5.18.1'
    - '/approved/perl/lib/5.18.1/i686-linux'
    - '/approved/perl/lib/5.18.1'
    - '.'

That's all folks!

# SYNOPSYS

    # Minimal setup: create a "wrapperl.env" file.
    # It is a Perl program to set up the right environment and
    # define the $PERL variable that points to the desired perl
    shell$ cat wrapperl.env
    $ENV{PERL5LIB} = '/path/to/some/lib:/path/to/another/lib';
    $PERL = '/path/to/bin/perl';

    # You can have a different "wrapperl.env" on each directory.
    # What is the one that we would see from here? "wrapperl" can
    # tell you this with -e | --env
    shell$ wrapperl -e
    /path/to/wrapperl.env

    # If you also provide a parameter to -e | --env, it will tell
    # you which environment file will be seen by the provided
    # parameter (that is of course expected to be a path)
    shell$ wrapperl -e /path/to/a/wrapperl/symlink
    /path/to/a/wrapper.env

    # Time to make it work! Option -x | --exec means calling it
    # as if it were the chosen perl with the configurations in
    # "wrapperl.env"
    shell$ wrapperl -x -le 'print $^X'
    /path/to/bin/perl

    # This is actually the default behaviour if the first parameter
    # is not supported by "wrapperl" directly, so the following calls
    # are equivalent. So, use -x if you need to pass the called perl
    # options -d, -e, -s or -x, otherwise you can avoid it
    shell$ wrapperl -x myprogram.pl --foo bar # OR
    shell$ wrapperl myprogram.pl --foo bar

    # Option -s | --sibling allows to call programs that are
    # usually shipped with perl, e.g. perlthanks, podchecker, etc.
    shell$ wrapperl -s podchecker myprogram.pl

    # Another useful option is -d | --doc to call perldoc quickly,
    # so the following ones are equivalent:
    shell$ wrapperl -s perldoc Module::Name
    shell$ wrapperl -d Module::Name

    # You can symlink wrapperl and it will do some magic.
    # Call the real program a name ending with ".pl" (e.g. "prg.pl")
    # and symlink wrapperl with the same name withouth the extension
    # (e.g. "prg"). This is what will happen:
    shell$ ls -l
    -rw-r--r-- 1 me me 74 Apr 23 22:20 wrapperl.env
    lrwxrwxrwx 1 me me  8 Apr 23 22:51 prg -> /path/to/wrapperl
    -rwxr-xr-x 1 me me 74 Apr 23 22:28 prg.pl

    shell$ cat prg.pl
    #!/usr/bin/env perl
    print "using perl '$^X', \@INC contains:\n";
    print "- '$_'\n" for @INC;

    shell$ cat wrapperl.env
    $ENV{PERL5LIB} = '/path/to/some/lib:/path/to/another/lib';
    $PERL = '/path/to/bin/perl';

    shell$ which perl
    /usr/bin/perl

    # If you call the program directly, wrapperl is not used of course
    shell$ ./prg.pl
    using perl '/usr/bin/perl', @INC contains:
    - '/etc/perl'
    - '/usr/local/lib/perl/5.14.2'
    - '/usr/local/share/perl/5.14.2'
    - '/usr/lib/perl5'
    - '/usr/share/perl5'
    - '/usr/lib/perl/5.14'
    - '/usr/share/perl/5.14'
    - '/usr/local/lib/site_perl'
    - '.'

    # On the other hand, if you call the "prg" symlink to wrapperl,
    # the same program above will be called, but with the perl and
    # options set in "wrapperl.env"
    shell$ ./prg
    using perl '/path/to/bin/perl', @INC contains:
    - '/path/to/another/lib/i686-linux'
    - '/path/to/another/lib'
    - '/path/to/some/lib/i686-linux'
    - '/path/to/some/lib'
    - '/path/to/lib/site_perl/5.18.1/i686-linux'
    - '/path/to/lib/site_perl/5.18.1'
    - '/path/to/lib/5.18.1/i686-linux'
    - '/path/to/lib/5.18.1'
    - '.'

    # There are two symlinks/names that trigger a special behaviour,
    # namely "perl" and "perldoc" that do what you think
    shell$ ls -l
    lrwxrwxrwx 1 me me  8 Apr 23 21:51 perl -> /path/to/wrapperl
    lrwxrwxrwx 1 me me  8 Apr 23 22:46 perldoc -> /path/to/wrapperl

    # The following two are therefore equivalent (and no, the
    # double "-x" is not an error, because the first is consumed by
    # "wrapperl" and the second one is for the invoked perl)
    shell$ ./perl -x /path/to/my/program.pl
    shell$ wrapperl -x -x /path/to/my/program.pl

    # These three are equivalent too
    shell$ ./perldoc My::Module
    shell$ wrapperl -d My::Module
    shell$ wrapperl -s perldoc My::Module

# DESCRIPTION

This program lets you wrap a perl program with some local-specific
configurations.

Why would you do this, e.g. as opposed to modifying the
_hash-bang_ line or setting `PERL5LIB`, or calling the perl
executable directly? Well, lazyness of course, but also the fact
that in different environments the same program might need different
configurations, and changing those configurations possibly in many
little Perl programs quickly becomes an error-prone hassle.

`wrapperl` provides you with a consistent, minimal and easy to setup
way to concentrate local-specific configurations in one single
file `wrapperl.env` (["The `wrapperl.env` File"](#the-wrapperl-env-file)), and be sure
that you will call your Perl program(s) with the right setup every time.

`wrapperl`'s behaviour strongly depends on its name. That is, if
you leave it as `wrapperl` it behaves in a specific way, while
if you name it differently then it does something else.

The easiest (and most robust) way to do the renaming is to use
symbolic links, if your filesystem allows you to. Otherwise, nothing
prevents you from copying `wrapperl` to whatever name you need and
get the benefits described below.

The following sections start by describing the `wrapperl.env` file
you should set up, then describe the behaviour in the different
conditions; among them, most probably you will be interested into
["Named Something Else"](#named-something-else). But first, something to set you to work
quickly.

## The `wrapperl.env` File

The `wrapperl.env` file is at the heart of the localization of
your configurations.

### Contents

The file is a standard Perl program. It will be called using whatever
_default_ perl is found, that is not what you are looking for most
probably (otherwise you would probably not be using `wrapperl` at
all). You can do whatever setting inside it, e.g. most probably you
will be interested in setting the environment variable `PERL5LIB`
to point towards the library directories you want to include in
`@INC`.

You can also affect how `wrapperl` works by setting the following
variables in package `main`:

- `$ME`

    the location of the original program invoked. When calling `wrapperl`
    with a different name (see ["Named Something Else"](#named-something-else)), it is used
    together with `$SUFFIX` described below to form the name of the
    program `$ME$SUFFIX` that will be called with the new `$PERL`. In
    general you should not need to fiddle with this.

- `$PERL`

    the path to the perl to use for invoking the other programs.

    By default it is set to the same perl that is executing `wrapperl`,
    namely `$^X`, just in case you need to setup `PERL5LIB`.

- `$PERLDOC`

    The name of the `perldoc` utility installed along with `$PERL`.

    By default it is set to `perldoc`, and you probably do not need
    to change it.

- `$SUFFIX`

    a suffix that is appended to the name of the invoked program when
    calling `wrapperl` with a different name (see
    ["Named Something Else"](#named-something-else)).

    The called program will be `$ME$SUFFIX`, so if `$SUFFIX` is set
    to `.pl`, you are expected to call your _real_ program the same
    as your symbolic link (or renamed `wrapperl` program) but with
    `.pl` appended. Example:

        shell$ ls -l
        lrwxrwxrwx 1 me me  8 Apr 23 22:51 prg -> /path/to/wrapperl
        -rwxr-xr-x 1 me me 74 Apr 23 22:28 prg.pl

    If your system is picky about how files should be named (e.g.
    Windows might put some restrictions to what it considers as
    _executables_), then you can do your transformations directly
    on `$ME` and set `$SUFFIX` to the empty string in order to
    select the _real_ program to call.

    By default, `$SUFFIX` is set to `.pl`.

### Loading

The `wrapperl.env` file is loaded via a `do`, so you are warned
about any possible security issue.

The invocation is supposed to return a true value (in Perl terms),
otherwise the execution will be stopped.

### Position

Depending on how `wrapperl` is called, the `wrapperl.env` file is
searched in different locations.

One or more
_starting positions_ will be considered, and used to perform a search
from that position upwards in the filesystem. For example, if the
starting point is `/path/to/some/internal/sub`, then the following
paths will be searched for `wrapperl.env`:

    /path/to/some/internal/sub
    /path/to/some/internal
    /path/to/some
    /path/to
    /path
    /

An exception is thrown if no `wrapperl.env` file is found during the
search in all the starting points.

The standard resolution of the `wrapperl.env` file is performed starting
from the current working directory, then from the user's home directory as
read from the `HOME` environment variable.

In some cases, the starting position will be some other specific
location. For example, when `wrapperl` is ["Named Something Else"](#named-something-else),
the only starting location will be the path to the link to
`wrapperl`, (i.e. what is used to initialize `$ME`).

## Direct Invocation

Direct invocation of `wrapperl` (i.e. without changing the name
when calling it) is subject to the processing of some
options (see ["OPTIONS"](#options)).

Unless otherwise noted, the resolution of the `wrapperl.env` file
is the _standard_ one as described in section ["Position"](#position).

If none of the options in ["OPTIONS"](#options) is recognised, the selected
perl in `$PERL` is invoked with whatever argument list is provided. This
is equivalent to using the `-x|--exec` option, except of course that the
first option is not stripped away in this case.

Option `-d|--doc` helps you call `perldoc`, or whatever is set in
`$PERLDOC`. This will be useful in order to use the `perldoc` that is
shipped with the selected `$PERL`, and more importantly with the same
options (e.g. `PERL5LIB`) set in `wrapperl.env`, so that you will be
able to find whatever module is installed in your personalized paths.

Option `-e|--env` helps you find out what will be the `wrapperl.env`
used, so that you can double check that it is the one you are expecting
and its contents. If you also pass a path in the command line, it will
be used as the starting point for searching `wrapperl.env`, otherwise
the standard resolution process is used.

Option `-s|--sibling` allows you to call one of the Perl programs
that are present in the same directory as `$PERL`, much in the same
way as described for `perldoc` above. For example, if you want to
check the POD documentation in `YourModule.pm` using the `podchecker`
that is shipped with the perl you indicated in `wrapperl.env`:

    shell$ wrapperl -s podchecker

Last, option `-x|--exec` allows you to call `$PERL` with the options
set in `wrapperl.env`. It is mostly unneeded, unless you want to
use any of the options above for calling `$PERL`.

## Named `perl`

This name makes `wrapperl` transform into a call to `$PERL` as
possibly set by the `wrapperl.env` file, including any command
line option provided. The behaviour is the same as calling
`wrapperl` with option `-x|--exec`.

The resolution of the `wrapperl.env` file is performed according to
the _standard resolution_ process explained in section ["Position"](#position).

## Named <perldoc>

This name calls the `perldoc` set in `$PERLDOC` and located in the
same directory as `$PERL`, including any command line option
provided. The behaviour is the same as calling `wrapperl` with
option `-d|--doc`.

The resolution of the `wrapperl.env` file is performed according to
the _standard resolution_ process explained in section ["Position"](#position).

## Named Something Else

The normal usage is intended to ease wrapping a call to your Perl
program so that the right perl binary with the right libraries is
used, without sacrificing simplicity.

Assuming that you have set up your `wrapperl.env` file (see
["The `wrapperl.env` File"](#the-wrapperl-env-file)), you are only two steps away from
using `wrapperl` to automate calling your program with the right
setup:

- you can write your program without worrying about which perl will
be used to call it or where the libraries are installed. Your only
constraint is to name it ending with `$SUFFIX` or do some magic
to `$ME` in `wrapperl.env` (see ["Contents"](#contents) for details).

    By default, it suffices that you name your program ending with
    `.pl`. For example, we will assume that your program is called
    `prg.pl`.

- You set up a copy to `wrapperl` to be called the same as your
program, but without the `$SUFFIX`. In the example, your copy
would be called `prg`.

    To make the copy you don't really have to make a copy! A symbolic
    link is sufficient, if your filesystem supports them.

This is really it! Now, every time you need to run your program...
don't do it, execute the `wrapperl` copy instead! That is, in the
example you would call `prg`, and it would in turn call your
`prg.pl` but after reading all the configurations
in `wrapperl.env`.

See ["TL;DR"](#tl-dr) for a complete and commented example.

# OPTIONS

When invoked with name `wrapperl`, this program supports the following
options. Note that you can provide one of them as the first option, and
anyone not appearing here will actually be used for invoking the
perl indicated in the `wrapperl.env` file.

In all the options below, unless otherwise noted, the
_standard resolution process_ for searching `wrapperl.env` is
used (see ["Position"](#position)).

- **-d | --doc \[arg1 arg2 ...\]**

    invoke whatever program is set in the `$PERLDOC` variable in package
    `main` (`perldoc` by default), using `$PERL` and the settings inside
    `wrapperl.env`.

    The `$PERLDOC` program is expected to be placed in
    the same directory as the selected `$PERL`.

- **-e | --env \[path\]**

    print the path to the `wrapperl.env` file.

    If a `path` is provided after this option, it is used as a starting
    location for searching `wrapperl.env`, otherwise the
    _standard resolution process_ is used. See ["Position"](#position) for additional
    details.

- **-s | --sibling name \[arg1 arg2 ...\]**

    invoke a _sibling_ program, i.e. a program that is shipped along
    with `$PERL` and is located in the same directory.

    The program is run with `$PERL` and the configurations set inside
    `wrapperl.env`. Any argument is provided on the command line is
    passed along to the sibling program. This will thus work fine
    when the sibling is a Perl program, but not for binary executables.

- **-x | --exec \[arg1 arg2 ...\]**

    invoke `$PERL` with the provided arguments, after loading the
    options in `wrapper.env`.

# DIAGNOSTICS

- `could not find wrapperl.env`

    `wrapperl` tried to find `wrapperl.env` in the same directory as
    the symbolic link to it, or in any ancestor directory, but failed to
    find one.

- `errors loading '%s'`

    loading the `wrapperl.env` was not successful, i.e. the invocation
    via `do` did not produce a true value. The placeholder provides
    the location of the offending file.

- `failed execution of %s`

    `wrapperl` tried to execute the command (reported in the error message)
    but failed. The placeholder provides the offending command.

- `something went really wrong`

    you shouldn't ever see this message, if you do it's a bug!

# CONFIGURATION AND ENVIRONMENT

`wrapperl` does not have a configuration per-se, but is of course
relying on the presence of a `wrapperl.env` file for proper
functioning - see ["DESCRIPTION"](#description).

# DEPENDENCIES

`wrapperl` relies on modules that are part of any standard Perl
distribution as of release 5.6.0.

# BUGS AND LIMITATIONS

Please report bugs and hopefully solutions through the GitHub
repository at [https://github.com/polettix/wrapperl](https://github.com/polettix/wrapperl).

# AUTHOR

Flavio Poletti <polettix@cpan.org>

# LICENSE AND COPYRIGHT

Copyright (c) 2015, Flavio Poletti `polettix@cpan.org`.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0. Please read
the full license in the `LICENSE` file inside the distribution,
as you can find at [https://github.com/polettix/wrapperl](https://github.com/polettix/wrapperl).

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
