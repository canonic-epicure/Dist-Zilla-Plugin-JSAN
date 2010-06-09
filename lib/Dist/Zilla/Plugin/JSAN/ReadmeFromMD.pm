package Dist::Zilla::Plugin::JSAN::ReadmeFromMD;

# ABSTRACT: build a README file

use Moose;
use Moose::Autobox;

use Dist::Zilla::File::InMemory;

extends 'Dist::Zilla::Plugin::Readme';


sub gather_files {
    my ($self) = @_;
    
    my $zilla           = $self->zilla;

    my $doc_file_md     = (join '/', ( 'doc', 'md', split /-/, $zilla->name )) . '.md';
    my $doc_file_mmd    = (join '/', ( 'doc', 'mmd', split /-/, $zilla->name )) . '.mmd';
    
    my $readme_file     = $zilla->files->grep(sub { $_->name eq $doc_file_md || $_->name eq $doc_file_mmd });
    
    if (@$readme_file) {
        $self->add_file(Dist::Zilla::File::InMemory->new({
            
            name    => 'README.md',
            
            content => $readme_file->[0]->content
        }));
    } else {
        $self->SUPER::gather_files()
    }
}


__PACKAGE__->meta->make_immutable;
no Moose;


1;


=head1 DESCRIPTION

This plugin adds a F<README.md> file to the distribution, which just copy the 
markdown (or multi-markdown) documentation file of the main module. Its useful for
GitHub, in which the README's conent shows at the projects home page. 

Of course, this plugins assumes, that your documentation is written in markdown and is already
generated. Therefor it should be included *after* the [JSAN] plugin.

If this plugin can't find the documentation file it falls back to standard [README] plugin behavior

=cut
