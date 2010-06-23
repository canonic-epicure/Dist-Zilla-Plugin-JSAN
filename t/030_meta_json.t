use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use Path::Class;
use JSON 2;

use Test::DZil;

{
    $ENV{JSANLIB} = dir('test_data', 'Bundle', 'jsan')->absolute() . '';
    
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/Bundle' },
    );

    $tzil->build;
    
    my $meta = decode_json($tzil->slurp_file(file(qw(build META.json))));
    
    ok($meta->{ static_dir } eq 'assets', 'Non-standard name for static dir was saved in META.json');
    ok($meta->{ requires }->{ 'Cool.Module' } eq '0.01', 'Requirements are written in META.json in correct format'); 
}

done_testing;
