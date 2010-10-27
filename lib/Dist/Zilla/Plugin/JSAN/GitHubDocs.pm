package Dist::Zilla::Plugin::JSAN::GitHubDocs;

# ABSTRACT: a plugin for Dist::Zilla which updates the 'gh-pages' branch after each release

use Moose;

use Archive::Tar;
use Git::Wrapper;
use Try::Tiny;


with 'Dist::Zilla::Role::AfterRelease';
with 'Dist::Zilla::Role::Git::DirtyFiles';


has 'push_to' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'origin'
);



sub after_release {
    my ($self, $archive) = @_;
    
    my @dirty_files = $self->list_dirty_files;
    
    if (@dirty_files) {
        
        $self->log_fatal("There are dirty files in the repo: [ @dirty_files ] - can't update gh-pages branch"); 
    }
    
    $self->log("Updating `gh-pages` branch");
    
    
    my $wrapper             = Git::Wrapper->new('.');
    my $current_branch      = ($wrapper->name_rev( '--name-only', 'HEAD' ))[0];
    
    try {
        $wrapper->checkout('gh-pages');
    } catch {
        $wrapper->checkout('-b', 'gh-pages');
    };
    
    my $tar     = Archive::Tar->new($archive);
    
    $tar->extract();
    
    
    $wrapper->commit('-a', -m => '`gh-pages` branch update');
    
    $wrapper->push($self->push_to, 'gh-pages');
    
    $wrapper->checkout($current_branch);
}



__PACKAGE__->meta->make_immutable;
no Moose;

1; 


=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN::GitHubDocs]
    push_to     = origin            ; default value
    

=head1 DESCRIPTION

After each release, this plugin will extract the content of tarball to the 'gh-pages' branch and push it
to the "push_to" remote.

=cut