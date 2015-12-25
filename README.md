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

## xs\_ok

    xs_ok $xs;
    xs_ok $xs, $message;

Compiles, links the given `XS` code and attaches to Perl.

If you use the special module name `TA_MODULE` in your `XS`
code, it will be replaced by an automatically generated
package name.  This can be useful if you want to pass the same
`XS` code to multiple calls to `xs_ok` without subsequent
calls replacing previous ones.

`$xs` may be either a string containing the `XS` code,
or a hash reference with these keys:

- xs

    The XS code.  This is the only required element.

- pxs

    The [ExtUtils::ParseXS](https://metacpan.org/pod/ExtUtils::ParseXS) arguments passes as a hash reference.

- verbose

    Spew copious debug information via test note.

You can use the `with_subtest` keyword to conditionally
run a subtest if the `xs_ok` call succeeds.  If `xs_ok`
does not work, then the subtest will automatically be
skipped.  Example:

    xs_ok $xs, with_subtest {
      # skipped if $xs fails for some reason
      my($module) = @_;
      plan 1;
      is $module->foo, 1;
    };

The module name detected during the XS parsing phase will
be passed in to the subtest.  This is helpful when you are
using a generated module name.

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
