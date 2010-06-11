package Dist::Zilla::MintingProfile::JSAN;
use Moose;
with 'Dist::Zilla::Role::MintingProfile';

=head1 DESCRIPTION

Default minting profile provider. The profile is a directory, containing arbitrary
files used during creation of new distribution. Among other things notably it should
contain the 'profile.ini' file, listing the plugins used for minter initialization.

This provider looks first in the ~/.dzil/profiles/$profile_name directory, if not found
it looks among the default profiles, shipped with Dist::Zilla.

=cut

1;
