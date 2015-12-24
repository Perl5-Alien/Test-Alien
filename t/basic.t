use strict;
use warnings;
use Test::Stream -V1;
use Test::Alien;

plan 2;

alien_ok 'Alien::Foo';

my $obj = Alien::Foo->new;

alien_ok $obj;

package
  Alien::Foo;

sub new { bless {}, __PACKAGE__ }
sub dist_dir     {}
sub cflags       {}
sub libs         {}
sub install_type {}
sub config       {}
sub dynamic_libs {}
sub bin_dir      {}
sub alien_helper {}
