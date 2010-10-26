package Dist::Zilla::Plugin::JSAN::GitHubDocs;

# ABSTRACT: a plugin for Dist::Zilla which updates the 'gh-pages' branch after each release

use Moose;
use Moose::Autobox;


use Path::Class;

with 'Dist::Zilla::Role::AfterRelease';


has 'extract' => (
    isa     => 'Str',
    is      => 'rw',
    default => '/doc/html'
);


has 'push_to' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'origin'
);



sub after_release {
    my ($self, $archive) = @_;
    
    $self->log("Updating `gh-pages` branch");
    
    my $args  = shift;
    my $src_dir = abs_path('.');

    my $src   = Git::Wrapper->new($src_dir);
    my $target_branch = _format_branch( $self->branch, $src );

    my $exists = eval { $src->rev_parse( '--verify', '-q', $target_branch ); 1; };

    eval {
        my $build = Git::Wrapper->new( $args->{build_root} );
        $build->init('-q');
        $build->remote('add','src',$src_dir);
        $build->fetch(qw(-q src));
        if($exists){
            $build->reset('--soft', "src/$target_branch");
        }
        $build->add('.');
        $build->commit('-a', -m => _format_message($self->message, $src));
        $build->checkout('-b',$target_branch);
        $build->push('src', $target_branch);
    };
    if (my $e = $@) {
        $self->log_fatal("failed to commit build: $e");
    }
}



__PACKAGE__->meta->make_immutable;
no Moose;

1; 


=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN::GitHubDocs]
    
    extract     = /doc/html         ; default value
    push_to     = origin            ; default value
    

=head1 DESCRIPTION

After each release, this plugin extract the directory "extract" from the tarball and update the 'gh-pages' branch with it.
It will then push the results to "push_to" config.

=cut