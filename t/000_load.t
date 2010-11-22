use strict;
use warnings;
use Test::More 0.88;

BEGIN {
	use_ok( 'Dist::Zilla::Plugin::JSAN' );
	use_ok( 'Dist::Zilla::Plugin::JSAN::Bundle' );
	use_ok( 'Dist::Zilla::Plugin::JSAN::Minter' );
	use_ok( 'Dist::Zilla::Plugin::JSAN::ReadmeFromMD' );
}

done_testing;