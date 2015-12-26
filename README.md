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
      my($module) = @_;
      ok $module->version;
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

Test that your library works with [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus):

    use Test::Stream -V1;
    use Test::Alien;
    use Alien::LibYAML;
    
    alien_ok 'Alien::LibYAML';
    ffi_ok { symbols => ['yaml_get_version'] }, with_subtest {
      my($ffi) = @_;
      my $get_version = $ffi->function(yaml_get_version => ['int*','int*','int*'] => 'void');
      $get_version->call(\my $major, \my $minor, \my $patch);
      like $major, qr{[0-9]+};
      like $minor, qr{[0-9]+};
      like $patch, qr{[0-9]+};
    };

# DESCRIPTION

This module provides tools for testing [Alien](https://metacpan.org/pod/Alien) modules.  It has hooks
to work easily with [Alien::Base](https://metacpan.org/pod/Alien::Base) based modules, but can also be used
via the synthetic interface to test non [Alien::Base](https://metacpan.org/pod/Alien::Base) based [Alien](https://metacpan.org/pod/Alien)
modules.  It has very modest prerequisites.

Prior to this module the best way to test a [Alien](https://metacpan.org/pod/Alien) module was via [Test::CChecker](https://metacpan.org/pod/Test::CChecker).
The main downside to that module is that it is heavily influenced by and uses
[ExtUtils::CChecker](https://metacpan.org/pod/ExtUtils::CChecker), which is a tool for checking at install time various things
about your compiler.  It was also written before [Alien::Base](https://metacpan.org/pod/Alien::Base) became as stable as it
is today.  In particular, [Test::CChecker](https://metacpan.org/pod/Test::CChecker) does its testing by creating an executable
and running it.  Unfortunately Perl uses extensions by creating dynamic libraries
and linking them into the Perl process, which is different in subtle and error prone
ways.  This module attempts to test the libraries in the way that they will actually
be used, via either `XS` or [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus).  It also provides a mechanism for
testing binaries that are provided by the various [Alien](https://metacpan.org/pod/Alien) modules (for example
[Alien::gmake](https://metacpan.org/pod/Alien::gmake) and [Alien::patch](https://metacpan.org/pod/Alien::patch)).

[Alien](https://metacpan.org/pod/Alien) modules can actually be useable without a compiler, or without [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)
(for example, if the library is provided by the system, and you are using [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus),
or if you are building from source and you are using `XS`), so tests with missing
prerequisites are automatically skipped.  For example, ["xs\_ok"](#xs_ok) will automatically skip
itself if a compiler is not found, and ["ffi\_ok"](#ffi_ok) will automatically skip itself
if [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) is not installed.

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

## ffi\_ok

    ffi_ok;
    ffi_ok \%opt;
    ffi_ok \%opt, $message;

Test that [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) works.

`\%opt` is a hash reference with these keys (all optional):

- symbols

    List references of symbols that must be found for the test to succeed.

- ignore\_not\_found

    Ignores symbols that aren't found.  This affects functions accessed via
    [FFI::Platypus#attach](https://metacpan.org/pod/FFI::Platypus#attach) and [FFI::Platypus#function](https://metacpan.org/pod/FFI::Platypus#function) methods, and does
    not influence the `symbols` key above.

- lang

    Set the language.  Used primarily for language specific native types.

As with ["xs\_ok"](#xs_ok) above, you can use the `with_subtest` keyword to specify
a subtest to be run if `ffi_ok` succeeds (it will skip otherwise).  The
[FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) instance is passed into the subtest as the first argument.
For example:

    ffi_ok with_subtest {
      my($ffi) = @_;
      is $ffi->function(foo => [] => 'void')->call, 42;
    };

# SEE ALSO

- [Test::Stream](https://metacpan.org/pod/Test::Stream)
- [Test::Alien::Run](https://metacpan.org/pod/Test::Alien::Run)
- [Test::Alien::CanCompile](https://metacpan.org/pod/Test::Alien::CanCompile)
- [Test::Alien::CanPlatypus](https://metacpan.org/pod/Test::Alien::CanPlatypus)
- [Test::Alien::Synthetic](https://metacpan.org/pod/Test::Alien::Synthetic)

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
