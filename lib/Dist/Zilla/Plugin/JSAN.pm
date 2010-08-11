package Dist::Zilla::Plugin::JSAN;

# ABSTRACT: a plugin for Dist::Zilla for building JSAN distributions


use Moose;
use Moose::Autobox;

use Path::Class;
use Dist::Zilla::File::InMemory;

extends 'Dist::Zilla::Plugin::ModuleBuild';


has 'mb_class' => (
    isa => 'Str',
    is  => 'rw',
    default => 'Module::Build::JSAN::Installable',
);


has 'docs_markup' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'mmd'
);


has 'static_dir' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'static'
);


sub _use_custom_class {
    my ($self) = @_;
    
    my $class = $self->mb_class;
    
    return "use $class;";
}


sub register_prereqs {
# don't add additional prepreqs as we are in JS land already
}


sub test {
# do nothing currently

#  my ($self, $target) = @_;
#
#  $self->build;
#  system($^X, 'Build', 'test') and die "error running $^X Build test\n";
#
#  return;
}


#==================================================================================================
# Copied from Dist::Zilla::Plugin::MetaJSON

with 'Dist::Zilla::Role::FileGatherer';

use CPAN::Meta::Converter 2.101550; # improved downconversion
use CPAN::Meta::Validator 2.101550; # improved downconversion
use Dist::Zilla::File::FromCode;
use Hash::Merge::Simple ();
use JSON 2;


has version => (
  is  => 'ro',
  isa => 'Num',
  default => '1.4',
);


sub add_meta_json {
  my ($self, $arg) = @_;

  my $zilla = $self->zilla;

  my $file  = Dist::Zilla::File::FromCode->new({
    name => 'META.json',
    code => sub {
      my $distmeta  = $zilla->distmeta;

      my $validator = CPAN::Meta::Validator->new($distmeta);

      unless ($validator->is_valid) {
        my $msg = "Invalid META structure.  Errors found:\n";
        $msg .= join( "\n", $validator->errors );
        $self->log_fatal($msg);
      }

      my $converter = CPAN::Meta::Converter->new($distmeta);
      
      my $output    = $converter->convert(version => $self->version);
      
      # the solely purpose of the copy-paste from Dist::Zilla::Plugin::MetaJSON
      $output->{ static_dir } = $self->static_dir;
      
      if ($output->{ requires }) {
          $output->{ requires } = $self->replace_colons_with_dots($output->{ requires } )
      }

      if ($output->{ build_requires }) {
          $output->{ build_requires } = $self->replace_colons_with_dots($output->{ build_requires })
      }
      
      
      JSON->new->ascii(1)->canonical(1)->pretty->encode($output) . "\n";
    },
  });

  $self->add_file($file);
  
  return;
}


sub replace_colons_with_dots {
    my ($self, $hash) = @_;
    
    my %replaced = map {
        (my $key = $_) =~ s/::/./g;
        
        $key => $hash->{ $_ };
    } keys %$hash;
    
    return \%replaced;
}

# EOF Copied from Dist::Zilla::Plugin::MetaJSON
#==================================================================================================


#================================================================================================================================================================================================================================================
sub gather_files {
    my $self = shift;
    
    $self->add_meta_json();
    
    my $markup = $self->docs_markup;
    
    my $method = "generate_docs_from_$markup";
    
    $self->$method();
}


#================================================================================================================================================================================================================================================
sub generate_docs_from_md {
    my $self = shift;
    
    require Text::Markdown;
    
    $self->extract_inlined_docs({
        html => \sub {
            my ($comments, $content) = @_;
            return (Text::Markdown::markdown($comments), 'html')
        },
        
        md => \sub {
            my ($comments, $content) = @_;
            return ($comments, 'md');
        }
    })
}


#================================================================================================================================================================================================================================================
sub generate_docs_from_mmd {
    my $self = shift;
    
    require Text::MultiMarkdown;
    
    $self->extract_inlined_docs({
        html => sub {
            my ($comments, $content) = @_;
            return (Text::MultiMarkdown::markdown($comments), 'html')
        },
        
        mmd => sub {
            my ($comments, $content) = @_;
            return ($comments, 'mmd');
        }
    })
}


#================================================================================================================================================================================================================================================
sub generate_docs_from_pod {
    my $self = shift;
    
    require Pod::Simple::HTML;
    require Pod::Simple::Text;
    require Pod::Select;
    
    $self->extract_inlined_docs({
        html => sub {
            my ($comments, $content) = @_;
            
            my $result  = '';
            my $parser  = Pod::Simple::HTML->new;
            
            $parser->output_string( \$result );
            
            $parser->parse_string_document($content);
            
            return ($result, 'html')
        },
        
        
        txt => sub {
            my ($comments, $content) = @_;
            
            my $result  = '';
            my $parser  = Pod::Simple::Text->new;
            
            $parser->output_string( \$result );
            
            $parser->parse_string_document($content);
            
            return ($result, 'txt')
        },
        
        
        pod => sub {
            my ($comments, $content) = @_;
            
            # XXX really extract pod using Pod::Select and temporary file
            return ($content, 'pod');
        }
    })
}


#================================================================================================================================================================================================================================================
sub find_dist_packages {
    my ($self) = @_;
    
    return $self->zilla->files->grep(sub { $_->name =~ m!^lib/.+\.js$! });
}


#================================================================================================================================================================================================================================================
sub find_file {
    my ($self, $file_name) = @_;
    
    return ( $self->zilla->files->grep(sub { $_->name eq $file_name }) )->[0];
}


#================================================================================================================================================================================================================================================
sub extract_inlined_docs {
    my ($self, $convertors) = @_;
    
    my $markup      = $self->docs_markup;
    my $lib_dir     = dir('lib');
    my $js_files    = $self->find_dist_packages;
    
    
    foreach my $file (@$js_files) {
        (my $separate_docs_file_name = $file->name) =~ s|\.js$|.$markup|;
        
        my $separate_docs_file   = $self->find_file($separate_docs_file_name);
        
        my $content         = $file->content;
        
        my $docs_content    = $separate_docs_file ? $separate_docs_file->content : $self->strip_doc_comments($content);


        foreach my $format (keys(%$convertors)) {
            
            #receiving formatted docs
            my $convertor = $convertors->{$format};
            
            my ($result, $result_ext) = &$convertor($docs_content, $content);
            
            
            #preparing 'doc' directory for current format 
            my $format_dir = dir('doc', $format);
            
            #saving results
            (my $res = $file->name) =~ s|^$lib_dir|$format_dir|;
            
            $res =~ s/\.js$/.$result_ext/;
            
            $self->add_file(Dist::Zilla::File::InMemory->new(
                name        => $res,
                content     => $result
            ));
        }
    }
}



#================================================================================================================================================================================================================================================
sub strip_doc_comments {
    my ($self, $content) = @_;
    
    my @comments = ($content =~ m[^\s*/\*\*(.*?)\*/]msg);
    
    return join '', @comments; 
}




__PACKAGE__->meta->make_immutable;
no Moose;

1; 

__END__




=head1 SYNOPSIS

In F<dist.ini>:

    name                = Sample-Dist
    abstract            = Some clever yet compact description
    
    author              = Clever Guy
    license             = LGPL_3_0
    copyright_holder    = Clever Guy
    
    
    ; version provider
    [BumpVersionFromGit]
    first_version = 0.01 
    
    
    ; choose/generate files to include
    
    [GatherDir]
    [PruneCruft]
    [ManifestSkip]
    [License]

    
    ; build system
    
    [ExecDir]
    [ShareDir]
    
    
    ; JSAN-specific configuration
    [JSAN]                            ; includes META.JSON generation
    docs_markup         = mmd         ; default
    static_dir          = static      ; default
    
    [JSAN::ReadmeFromMD]              ; should be after docs generation
    [JSAN::InstallInstructions]       ; add INSTALL file, describing the installation process
    [JSAN::Bundle]                    ; after docs generation to avoid docs for bundles
    
    ; manifest (after all generated files)
    [Manifest]
    
    
    ; before release
    
    [Git::Check]
    [CheckChangesHasContent]
    
    ; [TestRelease] todo
    [ConfirmRelease]
    
    ; releaser
    [JSAN::Upload]  ; just a no-op for now
     
     
    ; after release
    [Git::Commit / Commit_Dirty_Files]
     
    [Git::Tag]
     
    [NextRelease]
    format = %-9v %{yyyy-MM-dd HH:mm}d
    
    [Git::Commit / Commit_Changes]
     
    [Git::Push]
    push_to = origin
    
    [Twitter]
    tweet_url     = http://openjsan.org/go/?l={{ '{{ my $dist = $DIST; $dist =~ s/-/./g; $dist; }}' }}
    tweet         = Released {{ '{{$DIST}}-{{$VERSION}} {{$URL}}' }}
    hash_tags     = #jsan
       
    ; prerequisites
    
    [JSAN::Prereq]
    Joose                         = 3.010
    Cool.Module                   = 0.01

=cut


=head1 DESCRIPTION

This is a plugin for distribution-management tool L<Dist::Zilla>. It greatly simplifies the release process,
allowing you to focus on the code itself.

As the installer, this plugin use L<Module::Build::JSAN::Installable>, please RTFM.


=head1 PLUGINS

Any usual Dist::Zilla plugins can be used. In the SYNOPSIS above we've used L<Dist::Zilla::Plugin::Git::Check> and L<Dist::Zilla::Plugin::CheckChangesHasContent>.
Additionally several JSAN-specific plugins were added:

L<Dist::Zilla::Plugin::JSAN::ReadmeFromMD> - copies a main documentation file to the distribution root as README.md 

L<Dist::Zilla::Plugin::JSAN::InstallInstructions> - generates INSTALL file in the root of distribution with installation instructions

L<Dist::Zilla::Plugin::JSAN::Bundle> - concatenate individual source files into bundles, based on information from Components.JS file

L<Dist::Zilla::Plugin::JSAN::Prereq> - allows you to specify the dependencies for the distribution, using dot as namespace separator 
 


=head1 STARTING A NEW DISTRIBUTION

This plugin allows you to easily start a new JSAN distribution. Read to L<Dist::Zilla::Plugin::JSAN::Minter> know how.


=head1 AUTHOR

Nickolay Platonov, C<< <nplatonov at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dist-Zilla-Plugin-JSAN> or
L<http://github.com/SamuraiJack/Dist-Zilla-Plugin-JSAN/issues>.  
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

This module is stored in an open repository at the following address:

L<http://github.com/SamuraiJack/Dist-Zilla-Plugin-JSAN>


=head1 COPYRIGHT & LICENSE

Copyright 2010 Nickolay Platonov, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut


