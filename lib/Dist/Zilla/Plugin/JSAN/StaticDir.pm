package Dist::Zilla::Plugin::JSAN::StaticDir;

# ABSTRACT: Process "static" directory

use Moose;

use Path::Class;

with 'Dist::Zilla::Role::FileMunger';


sub dist_name_as_dir {
    my ($self) = @_;
    
    my $name = $self->zilla->name;
    
    return (split /-/, $name);
}


sub munge_file {
    my ($self, $file) = @_;
    
    my $static_dir = $self->zilla->plugin_named('JSAN')->static_dir;
    
    if ($file->name =~ m|^$static_dir|) {
        
        my $filename = dir('lib', $self->dist_name_as_dir, $file->name);
        
        $file->name($filename . "")
    }
    
}


no Moose;
__PACKAGE__->meta->make_immutable();


1;



=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN]
    static_dir = static ; default

    [JSAN::StaticDir]
    

=head1 DESCRIPTION

This plugin will move the "static" directory of your distribution into the "lib" folder, under its
distribution name. Please refer to L<Module::Build::JSAN::Installable> for details what is a "static" directory. 

Note, that the "static_dir" parameter by itself should be specified for the [JSAN] plugin, because its also 
needed for META.JSON generation.

=cut
