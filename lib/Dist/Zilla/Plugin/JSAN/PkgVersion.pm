package Dist::Zilla::Plugin::JSAN::PkgVersion;

# ABSTRACT: Embedd module version to sources

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
    
    my $content = $file->content;
    
    if ($content =~ m!
        ^(?'overall' (?'whitespace'\s*) /\*  VERSION  (?'comma',)?  \*/)  
    !msx) {
        
        my $overall             = $+{ overall };
        my $overall_quoted      = quotemeta $overall;
        
        my $comma               = $+{ comma } || '';
        my $whitespace          = $+{ whitespace };
        
        my $version             = $self->zilla->version;
        
        $version = "'$version'" if $version !~ m/^\d+(\.\d+)?$/;
        
        $content =~ s!$overall_quoted!${whitespace}VERSION : ${version}${comma}!;
        
        $file->content($content);
    }
}


no Moose;
__PACKAGE__->meta->make_immutable();


1;



=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN::PkgVersion]
    
In your sources:

    Class('Digest.MD5', {
        
        /*VERSION,*/
        
        has : {
            ...
        }
    })
    
will become after build:

    Class('Digest.MD5', {
        
        VERSION : 0.01,
         
        has : {
            ...
        }
    })
    

=head1 DESCRIPTION

This plugin will replace the 
    
    /*VERSION,*/ 
    
placeholders with the distribution version. Replacement will be  


=cut
