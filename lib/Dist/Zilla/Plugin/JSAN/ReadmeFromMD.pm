package Dist::Zilla::Plugin::JSAN::ReadmeFromMD;

# ABSTRACT: build a README file

use Moose;
use Moose::Autobox;

use Dist::Zilla::File::InMemory;

extends 'Dist::Zilla::Plugin::Readme';

with 'Dist::Zilla::Role::FileMunger';

use Path::Class;

has 'update_sources' => (
    is      => 'ro',
    isa     => 'Bool',
    
    default => sub { 1 }
);


has 'munge_not_add' => (
    is      => 'rw',
    isa     => 'Bool',
    
    default => sub { 0 }
);


sub gather_files {
    my ($self) = @_;
    
    my $zilla           = $self->zilla;

    my $readme_content  = $self->get_readme_markdown_content;
    
    return $self->SUPER::gather_files() unless $readme_content;
    
    if ($self->update_sources) {
        my $fh          = file('README.md')->openw;
        
        print $fh $readme_content;
        
        $fh->close;
    }
    
    
    my $readme_file     = $zilla->files->grep(sub { $_->name eq 'README.md' });
    
    if (@$readme_file) {
        $self->munge_not_add(1);
    } else {
        
        $self->add_file(Dist::Zilla::File::InMemory->new({
            
            name    => 'README.md',
            
            content => $readme_content
        }));
    }
}


sub munge_file {
    my ($self, $file) = @_;
    
    if ($file->name eq 'README.md' && $self->munge_not_add) {
        
        $file->content($self->get_readme_markdown_content)
    }
}


sub get_readme_markdown_content {
    my ($self) = @_;
    
    my $zilla           = $self->zilla;

    my $doc_file_md     = (join '/', ( 'doc', 'md',     split(/-/, $zilla->name) )) . '.md';
    my $doc_file_mmd    = (join '/', ( 'doc', 'mmd',    split(/-/, $zilla->name) )) . '.mmd';
    
    my $readme_file     = $zilla->files->grep(sub { $_->name eq $doc_file_md || $_->name eq $doc_file_mmd });
    
    if (@$readme_file) {
        return $readme_file->[0]->content;
    }
}


__PACKAGE__->meta->make_immutable;
no Moose;


1;

=head1 SYNOPSIS

In your F<dist.ini>:

  [JSAN::ReadmeFromMD]
  update_sources       = 1; this is a default
  
  
=head1 DESCRIPTION

This plugin adds a F<README.md> file to the distribution, which just copy the 
markdown (or multi-markdown) documentation file of the main module. 

By default it also modifies your sources and add the same file to the root of them.
Its useful for GitHub, in which the README's content shows at the projects home page.
You can disable this behavior with the F<update_sources> option, by setting it to 0.

Of course, this plugins assumes, that your documentation is written in markdown and is already
generated. Therefor it should be included *after* the [JSAN] plugin.

If this plugin can't find the documentation file it falls back to standard [README] plugin behavior

=cut
