use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use Path::Class;

use Test::DZil;

{
    $ENV{JSANLIB} = dir('build', 'jsan') . '';
    
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/Bundle' },
    );

    $tzil->build;
    
    my $contents = $tzil->slurp_file('build/README');
    
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

#{
#  my $tzil = Dist::Zilla::Tester->from_config(
#    { dist_root => 'corpus/DZT' },
#    {
#      add_files => {
#        'source/dist.ini' => simple_ini(
#          'GatherDir', [ 'ModuleBuild' => { mb_class => 'Foo::Build' } ],
#        ),
#      },
#    },
#  );
#
#  $tzil->build;
#
#  my $modulebuild = $tzil->plugin_named('ModuleBuild');
#
#  is(
#    $modulebuild->_use_custom_class,
#    q{use lib 'inc'; use Foo::Build;},
#    'loads custom class from inc'
#  );
#
#  my $build = $tzil->slurp_file('build/Build.PL');
#
#  like($build, qr/\QFoo::Build->new/, 'Build.PL calls ->new on Foo::Build');
#}

done_testing;
