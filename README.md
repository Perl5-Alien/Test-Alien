# Test::Alien [![Build Status](https://secure.travis-ci.org/plicease/Test-Alien.png)](http://travis-ci.org/plicease/Test-Alien)

Testing tools for Alien modules

# FUNCTIONS

## load\_alien

    load_alien $alien, $message;
    load_alien $alien;

Load the given [Alien](https://metacpan.org/pod/Alien) instance or class.  Checks that the instance or class conforms to the same
interface as [Alien::Base](https://metacpan.org/pod/Alien::Base).  Will be used by subsequent tests.

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
