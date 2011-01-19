package Dist::Zilla::Plugin::JSAN::OptimizePNG;

# ABSTRACT: a plugin for Dist::Zilla which optimize the PNG images

use Moose;
use Moose::Autobox;

with 'Dist::Zilla::Role::BeforeBuild';

use Deployer::Image::PNG;

use Path::Class;
use File::Find::Rule;


#================================================================================================================================================================================================================================================
sub mvp_multivalue_args { qw( dirs ) }
sub mvp_aliases { return { dir => 'dirs' } }


has dirs => (
    is   => 'ro',
    isa  => 'ArrayRef',
    default => sub { [] },
);


has only_for_release => (
    is      => 'rw',
    default => 1
);


has 'use_lossless' => (
    is => 'rw',
     
    default => 1
);


has 'use_quantization' => (
    is => 'rw',
     
    default => 1
);



has 'use_optipng' => (
    is => 'rw',
     
    default => 1
);


has 'use_pngout' => (
    is => 'rw',
     
    default => 0
);


has 'png_out_binary' => (
    is => 'rw'
);






#================================================================================================================================================================================================================================================
sub before_build {
    my ($self) = @_;
    
    return if ($self->only_for_release && !$ENV{ DZIL_RELEASING });

    my @png_files;
    
    foreach my $dir ($self->dirs->flatten) {
        push @png_files, File::Find::Rule->or(
            File::Find::Rule->file->name('*.png')
        )->in($dir);
    }
    
    
    foreach my $file (@png_files) {
        my $image = Deployer::Image::PNG->new({
            filename                => $file,
            
            use_lossless            => $self->use_lossless,
            use_quantization        => $self->use_quantization,
            
            use_pngout              => $self->use_pngout,
            use_optipng             => $self->use_optipng,
            png_out_binary          => $self->png_out_binary
        });
        
        my $before  = $image->get_size;
        
        $image->optimize();
        
        my $after   = $image->get_size;
        
        $self->log("File %100s: before=%7d, after=%7d, optimization=%.3f%%\n", $file, $before, $after, 100 * ($after - $before) / $before);
    }
    
}



no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);


1;


=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN::OptimizePNG]
    
    dir             = static/images/icons
    dir             = static/images/backgrounds
    
    use_lossless            = 1    ;    default, use lossless optimizations
    use_quantization        = 1    ;    default, use quantization (with losses)
    
    use_optipng             = 1    ;    default, use the `optipng` command for optimization 
                                   ;    (available from `optipng` package)
                               
    use_pngout              = 0    ;    default is to not use the `png_out` command 
                                   ;    (its provides much better compression than `optipng`
                                   ;    but is available only from http://www.advsys.net/ken/utils.htm
                                   
    png_out_binary          = script/bin/pngout-static  ; path to the `pngout` binary, if enabled                                    
                                     
    


=head1 DESCRIPTION



=cut
