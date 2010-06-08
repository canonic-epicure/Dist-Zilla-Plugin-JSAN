package Dist::Zilla::Plugin::JSAN::MetaJSON;

# ABSTRACT: produce a META.json using 1.4 version of CPAN meta-spec

use Moose;


extends 'Dist::Zilla::Plugin::MetaJSON';


has version => (
  is  => 'ro',
  isa => 'Num',
  default => '1.4',
);


no Moose;
__PACKAGE__->meta->make_immutable;

1;


=head1 DESCRIPTION

This plugin will add a F<META.json> file to the distribution.

The only difference from standard MetaJSON plugin is that the meta-spec version is defaulted to 1.4

=cut
