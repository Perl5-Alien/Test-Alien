# Test::Alien [![Build Status](https://secure.travis-ci.org/plicease/Test-Alien.png)](http://travis-ci.org/plicease/Test-Alien)

Testing tools for Alien modules

# SYNOPSIS

Test commands that come with your Alien:

    use Test::Stream -V1;
    use Test::Alien;
    use Alien::patch;
    
    plan 4;
    
    alien_ok 'Alien::patch';
    run_ok([ 'patch', '--version' ])
      ->success
      # we only accept the version written
      # by Larry ...
      ->out_like(qr{Larry Wall}); 

Test that your library works with `XS`:

    use Test::Stream -V1;
    use Test::Alien;
    use Alien::Editline;
    
    alien_ok 'Alien::Editline';
    my $xs = do { local $/; <DATA> };
    xs_ok $xs, with_subtest {
    };
    
    __DATA__
    
    #include "EXTERN.h"
    #include "perl.h"
    #include "XSUB.h"
    #include <editline/readline.h>
    
    const char *
    version(const char *class)
    {
      return rl_library_version;
    }
    
    MODULE = TA_MODULE PACKAGE = TA_MODULE
    
    const char *version(class);
        const char *class;

# DESCRIPTION

This module provides tools for testing [Alien](https://metacpan.org/pod/Alien) modules.  It has hooks
to work easily with [Alien::Base](https://metacpan.org/pod/Alien::Base) based modules, but can also be used
via the synthetic interface to test non [Alien::Base](https://metacpan.org/pod/Alien::Base) based [Alien](https://metacpan.org/pod/Alien)
modules.  It has very modest prerequisites.

**NOTE**: This module uses [Test::Stream](https://metacpan.org/pod/Test::Stream) instead of the classic [Test::More](https://metacpan.org/pod/Test::More).
As of this writing that makes it incompatible with the vast majority of
testing modules on CPAN.  This will change when/if [Test::Stream](https://metacpan.org/pod/Test::Stream) replaces
[Test::More](https://metacpan.org/pod/Test::More).  For the most part testing of [Alien](https://metacpan.org/pod/Alien) modules is done in
isolation to other testing libraries so that shouldn't be too terrible.

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

# CAVEATS

This module uses [Test::Stream](https://metacpan.org/pod/Test::Stream) instead of [Test::More](https://metacpan.org/pod/Test::More).

Although [Test::Stream](https://metacpan.org/pod/Test::Stream) has gone "stable" it is a relatively new
module, and thus the interface is probably still in a state of flux
to some extent.

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
