#!/usr/bin/perl

# ABSTRACT: embedd and escape template content 

use strict;
use warnings;


use Shotenjin::Embedder;

use Cwd;
use File::Find::Rule;
use Path::Class;
use Getopt::LL::Simple qw(
    --keep_whitespace|--kw
    --relative_cwd|--cwd
);


my $strip_whitespace    = $ARGV{'--strip_whitespace'};
my $relative_cwd        = $ARGV{'--relative_cwd'} || $ARGV{'--absolute'};
my $param               = $ARGV[0];


if ($param && -d $param) {
    
    Shotenjin::Embedder->process_dir($param, $strip_whitespace, $relative_cwd ? cwd() : undef);
    
} elsif ($param && -e $param) {
    
    Shotenjin::Embedder->process_file($param, $strip_whitespace, $relative_cwd ? cwd() : undef);
    
} else {
    die "Can't find input files to process, specify it as 1st argument\n(either single file or directory to scan)\n"
}


package shotenjin_embed; #just to satisfy PodWeaver

1;