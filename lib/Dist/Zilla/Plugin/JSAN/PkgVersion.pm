package Dist::Zilla::Plugin::JSAN::PkgVersion;

# ABSTRACT: Embedd module version to sources

use Moose;

use Path::Class;

with 'Dist::Zilla::Role::FileMunger';


has 'sources' => (
    is          => 'rw',
    
    default     => '^lib/.*\\.js$'
);



sub munge_files {
    my ($self) = @_;
    
    my $sources = $self->sources; 
    
    my $regex = qr/$sources/;
    
    
    for my $file (@{$self->zilla->files}) {
        
        next unless $file->name =~ m/$regex/;
    
        my $content             = $file->content;
        my $content_copy        = $content;
        
        pos $content = 0;
        
        
        while ($content =~ m!
            (?'overall' (?'whitespace'\s*) /\*  VERSION  (?'comma',)?  \*/)  
        !msxg) {
            
            my $overall             = $+{ overall };
            my $overall_quoted      = quotemeta $overall;
            
            my $comma               = $+{ comma } || '';
            my $whitespace          = $+{ whitespace };
            
            my $version             = $self->zilla->version;
            
            $version = "'$version'" if $version !~ m/^\d+(\.\d+)?$/;
            
            $content_copy =~ s!$overall_quoted!${whitespace}VERSION : ${version}${comma}!;
        }
        
        $file->content($content_copy) if $content_copy ne $content;
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
