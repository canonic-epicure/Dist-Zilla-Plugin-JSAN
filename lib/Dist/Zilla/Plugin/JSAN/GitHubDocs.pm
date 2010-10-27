package Dist::Zilla::Plugin::JSAN::GitHubDocs;

# ABSTRACT: a plugin for Dist::Zilla which updates the 'gh-pages' branch after each release

use Moose;

use Archive::Tar;
use Git::Wrapper;
use File::Temp;
use Path::Class;
use Cwd qw(abs_path);
use Try::Tiny;

with 'Dist::Zilla::Role::AfterRelease';
with 'Dist::Zilla::Role::Git::DirtyFiles';


has 'extract' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'doc/html'
);


has 'push_to' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'origin'
);


has 'redirect_prefix' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'doc/html'
);


sub dist_name_as_url {
    my ($self) = @_;
    
    return join '/', (split /-/, $self->zilla->name);
}


sub after_release {
    my ($self, $archive) = @_;
    
    my $git             = Git::Wrapper->new('.');
    my $gh_exists       = eval { $git->rev_parse( '--verify', '-q', 'gh-pages' ); 1; };
    
    
    my @dirty_files = $self->list_dirty_files($git);
    
    if (@dirty_files) {
        $self->log_fatal("There are dirty files in the repo: [ @dirty_files ] - can't update gh-pages branch"); 
    }
    
    $self->log("Updating `gh-pages` branch");
    
    
    # setting up the temporary git repo
     
    my $temp_dir        = File::Temp->newdir();
    my $git_gh_pages    = Git::Wrapper->new( $temp_dir . '');
    
    $git_gh_pages->init('-q');
    
    $git_gh_pages->remote('add', 'src', abs_path('.'));
    $git_gh_pages->fetch(qw(-q src));
    
    
    if ($gh_exists) {
        $git_gh_pages->checkout('remotes/src/gh-pages');
    } else {
        $git_gh_pages->symbolic_ref('HEAD', 'refs/heads/gh-pages');
        
        my $index_file = file($temp_dir, 'index.html');
        
        my $fh = $index_file->openw();
        
        my $redirect_url    = $self->redirect_prefix . '/' . $self->dist_name_as_url . '.html';
        
        print $fh <<INDEX
        
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="0;url=$redirect_url">
    </head>
    
    <body>
    </body>
</html>

INDEX
;
        $fh->close();        
    }


    # exracting the relevant files from tarball 
    
    my $extract = $self->extract;
    $extract =~ s!^/!!;
    
    $extract = qr/^$extract/; 
    
    my $next = Archive::Tar->iter($archive . '');
    
    while (my $file = $next->()) {
        
        my @extract_path = split '/', $file->full_path;
        
        shift @extract_path;
        
        my $extract_path = join '/', @extract_path;
        
        if ($extract_path =~ $extract) {
            $file->extract( $temp_dir . '/' . $extract_path ) or warn "Extraction failed";    
        }
    }    

    # pushing updates  
    
    $git_gh_pages->add('.');
    
    try {
        $git_gh_pages->commit('-m', '"gh-pages" branch update');
    } catch {
        # non-zero exit status if no files has been changed in docs
    };
    
    if ($gh_exists) {
        $git_gh_pages->checkout('-b', 'gh-pages');
    } 
    
    $git_gh_pages->push('src', 'gh-pages');
    
    $git->push($self->push_to, 'gh-pages');
    
    $self->log("`gh-pages` branch has been successfully updated");
}



__PACKAGE__->meta->make_immutable;
no Moose;

1; 


=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN::GitHubDocs]
    extract             = doc/html          ; default value
    redirect_prefix     = doc/html          ; default value
    push_to             = origin            ; default value
    

=head1 DESCRIPTION

After each release, this plugin will extract the documentation directory from the tarball (defined by the 'extract' argument) to the 'gh-pages' branch and push it
to the "push_to" remote. It will also add an "index.html" file, which simple redirects the user to the documentation file of the main module (using "redirect_prefix"
parameter).

=cut