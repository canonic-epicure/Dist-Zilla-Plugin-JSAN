use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use Path::Class;
use JSON 2;

use Test::DZil;

{
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/Readme' },
    );

    $tzil->build;
    
    my $build_dir = dir($tzil->tempdir, 'build');
    
    my $digest_content = $tzil->slurp_file(file(qw(build lib Digest MD5.js))) . "";
    
    ok($digest_content =~ /VERSION : 0.01,/, 'Correctly embedded version');
}

done_testing;
