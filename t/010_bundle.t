use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use Path::Class;

use Test::DZil;

{
    $ENV{JSANLIB} = dir('test_data', 'Bundle', 'jsan')->absolute() . '';
    
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/Bundle' },
    );

    $tzil->build;
    
    my $even_content            = $tzil->slurp_file(file(qw(build lib Task Digest MD5 Even.js)));
    my $odd_content             = $tzil->slurp_file(file(qw(build lib Task Digest MD5 Odd.js)));
    my $even_plus_odd_content   = $tzil->slurp_file(file(qw(build lib Task Digest MD5 EvenPlusOdd.js)));
    my $part21                  = $tzil->slurp_file(file(qw(build lib Task Digest MD5 Part21.js)));
    my $part22                  = $tzil->slurp_file(file(qw(build lib Task Digest MD5 Part22.js)));
    my $part23                  = $tzil->slurp_file(file(qw(build lib Task Digest MD5 Part23.js)));
    
    
    ok($even_content =~ /2;\s+4;/s, '`Even` bundle is correct');
    ok($odd_content =~ /1;\s+3;/s, '`Odd` bundle is correct');
    ok($even_plus_odd_content =~ /2;\s+4;\s+1;\s+3;/s, '`Odd` bundle is correct');
    ok($part23 =~ /jsan1;\s+part23;\s+jsan2;/s, '`Part23` bundle is correct');
    ok($part22 =~ /jsan1;\s+part23;\s+jsan2;\s+part22;/s, '`Part22` bundle is correct');
    ok($part21 =~ /jsan1;\s+part23;\s+jsan2;\s+part22;\s+part21;\s+jsan4;/s, '`Part21` bundle is correct');    

}

done_testing;
