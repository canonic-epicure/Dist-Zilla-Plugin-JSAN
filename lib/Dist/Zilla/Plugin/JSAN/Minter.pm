package Dist::Zilla::Plugin::JSAN::Minter;

# ABSTRACT: Default "minter"

use Moose;

extends 'Dist::Zilla::Plugin::JSAN::GatherDir::Template';

with 'Dist::Zilla::Role::FilePruner';
with 'Dist::Zilla::Role::FileMunger';


has 'include_dotfiles' => (
    is          => 'rw',
    default     => 1
);


sub exclude_file {
    my ($self, $file) = @_;

    my $main_perl_moudule    = $self->zilla->name;
    $main_perl_moudule       =~ s|-|/|g;

    return 1 if $file->name eq "lib/$main_perl_moudule.pm";
    return 1 if $file->name eq 'profile.ini';
    
    return 0;
}


sub prune_files {
    my ($self) = @_;

    my $files = $self->zilla->files;

    @$files = grep {
        $self->exclude_file($_) ? do { $self->log_debug([ 'pruning %s', $_->name ]); 0 } : 1
    } @$files;

    return;
}


sub dist_name {
    my ($self) = @_;
    
    my $name = $self->zilla->name;
    
    $name =~ s/-/\./g;
    
    return $name;
}


sub munge_file {
    my ($self, $file) = @_;
    
    return unless $file->name =~ m|^lib/Module/Stub\.(.+)$|;
    
    my $ext     = $1;
    my $name    = $self->zilla->name;
    
    $name       =~ s|-|/|g;
    
    
    $file->name("lib/$name.$ext")
}


no Moose;
__PACKAGE__->meta->make_immutable();


1;



=head1 SYNOPSIS

In your F<profile.ini>:

  [JSAN::Minter]

=head1 DESCRIPTION


=cut
