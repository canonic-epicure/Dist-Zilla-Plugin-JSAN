package Dist::Zilla::Plugin::JSAN::InstallInstructions;

# ABSTRACT: build an INSTALL file

use Moose;

use Dist::Zilla::File::InMemory;

use Data::Section 0.004 -setup;

with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::TextTemplate';


has 'filename' => (
    is      => 'rw',
    isa     => 'Str',
    
    default => 'INSTALL'
);


sub gather_files {
    my ($self) = @_;
    
    my $zilla           = $self->zilla;

    $self->add_file(Dist::Zilla::File::InMemory->new({
        name    => $self->filename,
        
        content => $self->fill_in_string(${$self->section_data('INSTALL')}, {
            dist    => \$zilla,
            plugin  => \$self
        })
    }));
}


sub dist_name {
    my ($self) = @_;
    
    my $name = $self->zilla->name;
    
    $name =~ s/-/\./g;
    
    return $name;
}



__PACKAGE__->meta->make_immutable;
no Moose;


1;

=head1 SYNOPSIS

In your F<dist.ini>:

  [JSAN::InstallInstructions]
  filename       = INSTALL; this is a default
  
  
=head1 DESCRIPTION

This plugin adds an F<INSTALL> file to the distribution, which describes the installation
process with JSAN::Shell. 

=cut


__DATA__
__[ INSTALL ]__
The installation procedure for {{ $plugin->dist_name }}


JSAN
====

`{{ $plugin->dist_name }}` is distributing via JSAN - [JavaScript Archive Network][jsan]. 
To install `{{ $plugin->dist_name }}` you'll need to install JSAN shell first - a small,
cross-platform, unix-shell-like program. It communicate directly with closest JSAN mirror 
and can download and install any JSAN module for you.

JSAN shell is written in perl, so the 1st step is to obtain Perl.


1. OBTAINING PERL
=================

Linux
-----

If you are on any relatively modern Linux distribution, you may skip this step, since you 
already have perl and all required perl modules. 


Windows
-------

Windows users should install [Strawberry perl][straberry]. Straberry perl is preferable than 
ActiveState perl, because it comes with the compiler included.

*NOTE:* After installation, you may need to relogin (or reboot) to see the updates in the PATH 
environment variable.


2. INSTALLING SHELL
===================

Launch a console (`cmd` on Windows). Then type:

       > cpan JSAN::Shell
    
Thats all, now wait until shell will be installed. You may be asked about installing 
its pre-requisites - answer 'yes'. 


3. INSTALLING `{{ $plugin->dist_name }}`
==========================

Launch a console (`cmd` on Windows). Then type:
    
        > jsan
    
This should launch a JSAN shell and display a prompt, similar to this:
    
        Checking for Internet access...
        Locating closest JSAN mirror...
        
        jsan shell -- JSAN repository explorer and package installer (v2.03)
                   -- Copyright 2005 - 2009 Adam Kennedy.
                   -- Type 'help' for a summary of available commands.
        
        jsan>
    
If this is the first time you installing the JSAN module, setup the installation path 
('prefix' setting can be saved, so you won't need to enter it again):
        
        jsan> set prefix /your/installation/path/

Then, type:
        
        jsan> install {{ $plugin->dist_name }}

Thats all, shell will download and install `{{ $plugin->dist_name }}` for you. 

For the list of available commands, try `help`. Also refer to 
[JSAN::Shell documentation](http://search.cpan.org/dist/JSAN-Shell/lib/JSAN/Shell.pm) for details. 


4. CONFIGURING YOUR SYSTEM
==========================

After successful completion of the procedure above, `{{ $plugin->dist_name }}` will be 
installed in your local JavaScript library (you've specified its location with 'prefix').

For example, the path to the library can be:

- /usr/local/lib/jsan

on Linux systems

- c:\JSAN

on Windows systems.

As a convention, its recommended to configure you local web server (you have one installed, right?) 
that way, that the root starting url `/jsan` will point at the `lib` subdirectory of 
JSAN library: `/usr/local/lib/jsan/lib` for example.

This way you can load any installed JSAN module via url like: `/jsan/Useful/Module/Name.js`



AUTHOR
======

{{ $OUT .= $_ . "\n\n" foreach (@{$dist->authors})  }}


COPYRIGHT AND LICENSE
=====================

{{ $dist->license->notice }}

[jsan]: http://openjsan.org
[straberry]: http://strawberryperl.com/
