# NAME

wrapperl - simple wrapper system for Perl

# SYNOPSYS

    # the "real" Perl program goes into somename.pl
    $ vi somename.pl # and put your stuff inside

    # the "wrapper" is a symlink to wrapperl, named somename
    # in same directory as somename.pl
    $ ln -s /path/to/wrapperl somename

    # the configuration is put in a wrapperl.env file, which is
    # actually a Perl file with a configuration inside. It is put
    # in the same directory or any ancestor as somename.pl/somename
    $ cat wrapperl.env
    $ENV{PERL5LIB} = '';
    '/path/to/perl';

# DESCRIPTION

This program lets you wrap a perl program with some local-specific
configurations.

## Normal Usage

Using it is simple and has three steps:

1. you assign your program a name that ends in `.pl`, e.g. `somename.pl`;
2. you create a symbolic link to `wrapperl` inside the same directory
as your program, and name the symbolic link the same as the program
but without the `.pl` extension, e.g. `somename`;
3. you create a small Perl program called `wrapperl.env` located inside the
same directory as the main program, or any of its ancestors (the first
that is found while backtracking is used).

This small program in the third step is supposed
to set the needed environment variables, like `$ENV{PERL5LIB}`, and also
return the path to the `perl` program to use for invoking the program
in the modified environment. If you want to reuse the same `perl`, just
use `$^X` as the last statement in your `wrapperl.env` file, otherwise
put a string with the desired path.

This is really it! Now you can call the symbolic link created in step
2, and the real program in step 1 will be called actually, in the modified
environment and with the `perl` you set inside the `wrapperl.env` file.

## Special Names

As it should be evident at this point, this program acts depending on
the name it is called with. While in general the behaviour is what
has been described in the previous section, there are some names that
are treated in a special way:

- **wrapperl**

    when invoked directly (or anyway through a symlink called `wrapperl`),
    the program will show what environment file `wrapperl.env` is used. You
    can pass a path to set the starting point for the research of the file,
    otherwise it will start from the current working directory and in case
    of absence from the home directory.

- **perl**

    this name makes `wrapperl` transform into a call to the `perl` indicated
    by the `wrapperl.env` file, with all following command line options.

- **perldoc**

    this name calls the `perldoc` program located in the same directory
    as the loaded `perl`, with following parameters.

This means that you can symlink with name `perl` and get a way to
invoke `perl` with the right parameters set in the `wrapperl.env`
file.

## `wrapperl.env`

The `wrapperl.env` file is executed via a `do`, so you are warned
about any possible security issue.

You can of course do whatever you want in this file, including the
modification of the relevant variables:

- `$ME`

    this is the absolute path to the invoked program (most probably, a
    symlink to `wrapperl`). In case of "regular" invocation, i.e. through
    a name that is not special, the real target is derived as
    `$ME$SUFFIX`, so if you modify either one you can influence which
    target name to use.

    In case of `perldoc`, `$ME` is used to find the last part (i.e.
    the _basename_) and is then used **without** the `$SUFFIX`.

- `$SUFFIX`

    this is a suffix appended to the invoked name `$ME` to find the real
    Perl program to start. Defaults to `.pl`.

# OPTIONS

This program really has no options.

# DIAGNOSTICS

- `could not find wrapperl.env`

    `wrapperl` tried to find `wrapperl.env` in the same directory as
    the symbolic link to it, or in any ancestor directory, but failed to
    find one.

- `reading %s failed`

    the `wrapperl.env` file that was found cannot be read properly. The
    error message indicates the path to the troublesome file.

- `failed execution of %s`

    `wrapperl` tried to execute the command (reported in the error message)
    but failed.

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
