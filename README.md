# NAME

wrapperl - wrapper for Perl customized invocation

# Hurry Up!

    # download in "visible" location
    cd /usr/bin
    # alias wget='curl -LO' # in case you need it
    wget https://raw.githubusercontent.com/polettix/wrapperl/master/wrapperl
    chmod +x wrapperl 

    # set wrapperl.env for your project. Suppose you have a 'lib' directory
    # with your stuff inside, and a 'local/lib/perl5' directory with the
    # local installation of support modules, all inside /path/to/project
    cd /path/to/project
    cat > wrapperl.env <<END
    PERL5LIB(qw< lib local/lib/perl5 >);
    PERL('/path/to/selected/bin/perl');
    END

    # start using it, most straightforward way is from hash-bang
    cat > program.pl <<END
    #!/usr/bin/env wrapperl
    print "using perl '$^X', \@INC contains:\n";
    print "- '$_'\n" for @INC;
    END
    ./program.pl
    # ...

    # you can access docs for locally installed modules
    wrapperl -d Log::Log4perl::Tiny

# TL;DR

... or an example is worth a whole manual sometimes.

First of all, download `wrapperl` from
[https://raw.githubusercontent.com/polettix/wrapperl/master/wrapperl](https://raw.githubusercontent.com/polettix/wrapperl/master/wrapperl)
and put somewhere in the environments where you need it. It is not
necessary to put it in a directory in the `PATH`, although it is
suggested in order to access all functionalities and it will also be
assumed in the following of this example.

Let's make a few assumptions:

- you are in a sane environment where you managed to put `wrapperl`
somewhere in your `PATH` and you have a working `/usr/bin/env` (this
assumption is not so strong, as you can understand, but will help us
set a consistent hash-bang)
- you will write your program and we will call it `prg`. To get the gist
of `wrapperl` you can start from this:

        #!/usr/bin/env wrapperl
        print "using perl '$^X', \@INC contains:\n";
        print "- '$_'\n" for @INC;

    If you didn't manage to put `wrapperl` in `PATH`, or you don't have
    `/usr/bin/env`, just put the path to `wrapperl` in the _hash-bang_,
    although you will then need to ensure that this choice will be
    true on all systems

- you do your coding in a development environment where:
    - you develop `prg` inside directory `/home/me/program`
    - `perl` is located at `/home/me/perl/bin/perl`
    - the modules you develop in association with `prg` are located in
    sub-directory `lib`. In addition, you keep a local library of
    support modules in sub-directory `local/lib/perl5` and you also
    want to include modules from non-standard absolute location
    `/path/to/some/lib` and relative location `another/lib` with respect
    to where you are calling the program for (you are generally advised
    against this, but the example shows that you can)
- you deploy your program in a production environment with a different
setup, namely:
    - your program `prg.pl` is deployed in directory `/app/program`
    - `perl` is located at `/approved/perl/bin/perl`
    - you still keep the layout with the `lib` and `local/lib/perl5`
    sub-directories, but all system-wide modules you need
    are stored in `/approved/lib`.

In both environments, you create a `wrapperl.env` file inside the root
directory of your project, which will hold configurations
that are specific for the specific environment it is located into.
In this example we will put it in the same directory as `prg`.

This is what you end up with in the development environment:

    me@devhost /home/me/program$ ls -l
    -rwxr-xr-x 1 me me 74 Apr 23 22:28 prg
    -rwxr-xr-x 1 me me 90 Apr 22 12:35 wrapperl.env

    me@devhost /home/me/program$ cat wrapperl.env
    PERL5LIB(
       qw< lib local/lib/perl5 >, # located as siblings of wrapperl.env
       [ qw< /path/to/some/lib another/lib > ],    # non-siblings paths
    );
    PERL('/home/me/perl/bin/perl');

This is what you have in the production environment:

    me@production /app/program$ ls -l
    -rwxr-xr-x 1 me me 74 Apr 25 20:51 prg
    -rwxr-xr-x 1 me me 66 Apr 25 20:51 wrapperl.env

    me@production /app/program$ cat wrapperl.env
    PERL5LIB(
       qw< lib local/lib/perl5 >, # located as siblings of wrapperl.env
       [ qw< /approved/lib > ],   # non-siblings paths
    );
    PERL('/approved/perl/bin/perl');

So yes, they two setups are mostly the same, except for the contents
of the `wrapperl.env` files, each containing configurations that
are environment-specific. You should be able to easily guess what the
two functions `PERL5LIB` and `PERL` do.

Now, you just execute your program. In the development environment:

    me@devhost /home/me/program$ ./prg
    using perl '/home/me/perl/bin/perl', @INC contains:
    - '/home/me/program/lib'
    - '/home/me/program/local/lib/perl5/i686-linux'
    - '/home/me/program/local/lib/perl5'
    - '/path/to/some/lib/i686-linux'
    - '/path/to/some/lib'
    - '/home/me/program/another/lib/i686-linux'
    - '/home/me/program/another/lib'
    - '/home/me/perl/lib/site_perl/5.18.1/i686-linux'
    - '/home/me/perl/lib/site_perl/5.18.1'
    - '/home/me/perl/lib/5.18.1/i686-linux'
    - '/home/me/perl/lib/5.18.1'
    - '.'

In the production environment:

    me@production /app/program$ ./prg
    using perl '/approved/perl/bin/perl', @INC contains:
    - '/app/program/lib'
    - '/app/program/local/lib/perl5/i686-linux'
    - '/app/program/local/lib/perl5'
    - '/approved/lib/i686-linux'
    - '/approved/lib'
    - '/approved/perl/lib/site_perl/5.18.1/i686-linux'
    - '/approved/perl/lib/site_perl/5.18.1'
    - '/approved/perl/lib/5.18.1/i686-linux'
    - '/approved/perl/lib/5.18.1'
    - '.'

One last hint! If you cannot manage to install `wrapperl` somewhere
in the `PATH` in all the environments, you can either do some shell
wrapping (but this would somehow make wrapperl slightly overkill
probably) or use an approach based on symbolic links. If this is the
case:

- rename your program `prg` as `prg.pl`, i.e. ending in suffix `.pl`
- in the same directory, create a symbolic link named `prg` and pointing
to the location of `wrapperl` (which could be in the very same directory
if you plan to ship wrapperl as well)

With this setup, when you run the symbolic link, it will just run the
associated `.pl` file with the settings in the `wrapperl.env` file.

That's all folks!

# SYNOPSYS

    # Minimal setup: create a "wrapperl.env" file.
    # It is a Perl program to set up the right environment.
    # Two handy functions PERL5LIB() and PERL() are all you need usually
    shell$ cat wrapperl.env
    PERL5LIB(qw< lib llib > [qw< /path/to/lib /path/to/other/lib >]);
    PERL('/path/to/bin/perl');

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

    # Option -s | --sibling allows to call programs that are
    # usually shipped with perl, e.g. perlthanks, podchecker, etc.
    shell$ wrapperl -s podchecker myprogram.pl

    # Another useful option is -d | --doc to call perldoc quickly,
    # so the following ones are equivalent but the latter is less typing
    shell$ wrapperl -s perldoc Module::Name
    shell$ wrapperl -d Module::Name

    # If the first parameter is not supported by "wrapperl" directly,
    # it will be considered a perl program to be executed along with
    # its own parameters. This makes it handy to use wrapperl in
    # hash-bang setups. The program's *realpath* is also used as the
    # starting point for searching wrapperl.env, so that symbolic
    # links to your program should work as expected
    shell$ wrapperl myprogram.pl --foo bar

    # You can symlink pointing to wrapperl and it will do some magic.
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

    # Last, if you manage to install wrapperl somewhere in the PATH
    # you can spare the symbolic link and use the hash bang directly!
    shell$ cat hashbanged-program
    #!/usr/bin/env wrapperl
    print "using perl $^X\n";
    print "$_\n" for @INC;

    shell$ ./hashbanged-program
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
way to concentrate local-specific configurations in the
["The `wrapperl.env` File"](#the-wrapperl-env-file), and be sure
that you will call your Perl program(s) with the right setup every time.

`wrapperl`'s behaviour strongly depends on its name. That is, if
you leave it as `wrapperl` it behaves in a specific way, while
if you name it differently then it does something else.

You have several options to do call `wrapperl` with a different name:

- you just copy it with a different name. It works but it's also ugly
and it will be a hassle every time you want to upgrade (but chances are
you will not need. so don't worry too much)
- you create a symbolic link. Works if your filesystem supports them,
is robust and allows you to avoid touching the main program
- if you can put `wrapperl` somewhere in the path in all your
environments, and your system supports the _hash-bang_ system
(i.e. you're in some Unix-ish system), you can just set it inside
the main program and avoid having anything more. Very clean and
suggested if possible!

The following sections start by describing the `wrapperl.env` file
you should set up, then describe the behaviour in the different
conditions; among them, most probably you will be interested into
["Named Something Else"](#named-something-else).

## The `wrapperl.env` File

The `wrapperl.env` file is at the heart of the localization of
your configurations.

### Contents

The file is a standard Perl program. It will be called using whatever
_default_ perl is found, that is not what you are looking for most
probably (otherwise you would probably not be using `wrapperl` at
all). You can do whatever setting inside it, while most probably you
will be interested in setting the environment variable `PERL5LIB`
to point towards the library directories you want to include in
`@INC`, and also set the right Perl executable to use.

You can affect how `wrapperl` works by calling the following
functions from within a `wrapperl.env` file (you should normally
only need the first two anyway):

- **PERL($path)**

    the path to the perl to use for invoking the other programs.

    By default it is set to the same perl that is executing `wrapperl`,
    namely `$^X`, just in case you need to setup `PERL5LIB` only.

- **PERL5LIB(@items)**

    set the environment variable `PERL5LIB` according to your needs. You
    can pass a list of items, each of which can be:

    - a string, that is interpreted as a relative path starting from the
    same directory as where `wrapperl.env` is put. This allows e.g. to
    make sure you can point towards sub-directories `lib` and
    `local/lib/perl5` inside your project's root directory, provided you
    also put `wrapperl.env` in the same directory
    - a reference to an array of strings. These strings are passed unchanged
    in the environment variable, so that you can set either absolute
    paths or paths relative to the current directory.

    You should normally need to set paths relative to the root directory
    of your project, this is why it's slightly easier to set them instead
    of absolute paths or paths relative to the current directory.

    Any previous value of the environment variable `PERL5LIB` is wiped
    out, and this is considered a feature. If you really want to preserve
    it somewhere, just pass its value inside a reference to an array like
    this:

        PERL5LIB(..., [$ENV{PERL5LIB}], ...);

- **ME($path)**

    the location of the original program invoked. When calling `wrapperl`
    with a different name (see ["Named Something Else"](#named-something-else)), it is used
    together with `$SUFFIX` described below to form the name of the
    program `$ME$SUFFIX` that will be called with the new `$PERL`. In
    general you should not need to fiddle with this.

- **PERLDOC($name)**

    The name of the `perldoc` utility installed along with `$PERL`.

    By default it is set to `perldoc`, and you probably do not need
    to change it.

- **SUFFIX($string)**

    a suffix that is appended to the name of the invoked program when
    calling `wrapperl` with a different name (see
    ["Named Something Else"](#named-something-else)). Makes sense only if you are using the
    symbolic linking method and not the _hash-bang_ approach.

    Assuming that `$ME` holds the value set by `ME()` and `$SUFFIX`
    the value set by `SUFFIX`,
    the called program will be `$ME$SUFFIX`, so if `$SUFFIX` is
    `.pl`, you are expected to call your _real_ program the same
    as your symbolic link (or renamed `wrapperl` program) but with
    `.pl` appended. Example:

        shell$ ls -l
        lrwxrwxrwx 1 me me  8 Apr 23 22:51 prg -> /path/to/wrapperl
        -rwxr-xr-x 1 me me 74 Apr 23 22:28 prg.pl

    If your system is picky about how files should be named (e.g.
    Windows might put some restrictions to what it considers as
    _executables_), then you can do your transformations directly
    using `ME()` and set `SUFFIX('')` to the empty string in order
    to select the _real_ program to call.

    By default, it is set to `.pl` and you should not need
    to change it.

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

The _standard resolution_ of the `wrapperl.env` file is performed starting
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

If none of the options in ["OPTIONS"](#options) is recognized, the selected
perl via `PERL()` is invoked with whatever argument list is provided. This
is equivalent to using the `-x|--exec` option, except that the
first option is not stripped away in this case and also that the first
item in the command line list is assumed to be the path to a program and
its path will be used as the starting position for `wrapperl.env`
location resolution.

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
set in `wrapperl.env` (where the resolution process starts from the
current directory or from the `HOME` directory).

## Named `perl`

This name makes `wrapperl` transform into a call to what set as
`PERL()`, including any command line option provided.

The resolution of the `wrapperl.env` file is performed according to
the _standard resolution_ process explained in section ["Position"](#position),
starting from the location of the symbolic link.

## Named <perldoc>

This name calls the `perldoc` set via `PERLDOC()` and located in the
same directory as what set via `PERL()`, including any command line
option provided. The behaviour is the same as calling `wrapperl` with
option `-d|--doc`, with the exception of the resolution process.

The resolution of the `wrapperl.env` file is performed according to
the _standard resolution_ process explained in section ["Position"](#position),
starting from the location of the symbolic link.

## Named Something Else

If your system(s) have `/usr/bin/env` and you can put `wrapperl`
somewhere in the `PATH`, just set the _hash-bang_ to:

    #!/usr/bin/env wrapperl

and you're done. If not, read on.

Assuming that you have set up your `wrapperl.env` file (see
["The `wrapperl.env` File"](#the-wrapperl-env-file)), you are only two steps away from
using `wrapperl` to automate calling your program with the right
setup:

- you can write your program without worrying about which perl will
be used to call it or where the libraries are installed. Your only
constraint is to name it ending with what is set for `SUFFIX()` or
do some magic using `ME()` in `wrapperl.env`.

    By default, it suffices that you name your program ending with
    `.pl`. For example, we will assume that your program is called
    `prg.pl`.

- You set up a copy to `wrapperl` to be called the same as your
program, but without the `SUFFIX`. In the example, your copy
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

- **-x | --exec program \[arg1 arg2 ...\]**

    invoke `$PERL` with the provided program and arguments, after loading
    the options in `wrapper.env`. The `wrapperl.env` resolution is performed
    starting from the _realpath_ of `program` (see ["Cwd"](#cwd)).

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
