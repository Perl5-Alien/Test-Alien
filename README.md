# Test::Alien [![Build Status](https://secure.travis-ci.org/plicease/Test-Alien.png)](http://travis-ci.org/plicease/Test-Alien)

Testing tools for Alien modules

# FUNCTIONS

## alien\_ok

    alien_ok $alien, $message;
    alien_ok $alien;

Load the given [Alien](https://metacpan.org/pod/Alien) instance or class.  Checks that the instance or class conforms to the same
interface as [Alien::Base](https://metacpan.org/pod/Alien::Base).  Will be used by subsequent tests.

## run\_ok

    my $run = run_ok $command;
    my $run = run_ok $command, $message;

Runs the given command, falling back on any `Alien::Base#bin_dir` methods provided by [Alien](https://metacpan.org/pod/Alien) modules
specified with ["alien\_ok"](#alien_ok).

`$command` can be either a string or an array reference.

Only fails if the command cannot be found, or if it is killed by a signal!  Returns a [Test::Alien::Run](https://metacpan.org/pod/Test::Alien::Run)
object, which you can use to test the exit status, output and standard error.

Always returns an instance of [Test::Alien::Run](https://metacpan.org/pod/Test::Alien::Run), even if the command could not be found.

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
