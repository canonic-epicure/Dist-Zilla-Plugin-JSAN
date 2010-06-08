package Dist::Zilla::Plugin::JSAN;

use Moose;

extends 'Dist::Zilla::Plugin::ModuleBuild';


has 'mb_class' => (
    isa => 'Str',
    is  => 'rw',
    default => 'Module::Build::JSAN::Installable',
);


has 'docs_markup' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'pod'
);


sub customize_module_build_args {
    
}


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

__PACKAGE__->meta->make_immutable;
no Moose;

1; 

__END__

=head1 NAME

Module::Build::JSAN::Installable - Build JavaScript distributions for JSAN, which can be installed locally

=head1 SYNOPSIS

In F<Build.PL>:

  use Module::Build::JSAN::Installable;

  my $build = Module::Build::JSAN::Installable->new(
      module_name    => 'Foo.Bar',
      license        => 'perl',
      keywords       => [qw(Foo Bar pithyness)],
      requires     => {
          'JSAN'     => 0.10,
          'Baz.Quux' => 0.02,
      },
      build_requires => {
          'Test.Simple' => 0.20,
      },
      
      static_dir => 'assets',
      docs_markup => 'mmd'
  );

  $build->create_build_script;


To build, test and install a distribution:

  % perl Build.PL
  % ./Build
  % ./Build test  
  % ./Build install


In F<Components.js>:

    COMPONENTS = {
        
        "Kernel" : [
            "JooseX.Namespace.Depended.Manager",
            "JooseX.Namespace.Depended.Resource",
            
            "JooseX.Namespace.Depended.Materialize.Eval",
            "JooseX.Namespace.Depended.Materialize.ScriptTag"
        ],
        
        
        "Web" : [
            "+Kernel",
        
            "JooseX.Namespace.Depended.Transport.AjaxAsync",
            "JooseX.Namespace.Depended.Transport.AjaxSync",
            "JooseX.Namespace.Depended.Transport.ScriptTag",
            
            "JooseX.Namespace.Depended.Resource.URL",
            "JooseX.Namespace.Depended.Resource.URL.JS",
            "JooseX.Namespace.Depended.Resource.JS",
            "JooseX.Namespace.Depended.Resource.JS.External",
            
            //should be the last        
            "JooseX.Namespace.Depended"
        ],
        
        
        "ServerJS" : [
            "+Kernel",
            
            "JooseX.Namespace.Depended.Transport.Require",
            "JooseX.Namespace.Depended.Resource.Require",
            
            //should be the last
            "JooseX.Namespace.Depended"
        ]
        
    } 


=cut


=head1 DESCRIPTION

This is a developer aid for creating JSAN distributions, which can be also installed in the local system. JSAN is the
"JavaScript Archive Network," a JavaScript library akin to CPAN. Visit
L<http://www.openjsan.org/> for details.

This module works nearly identically to L<Module::Build::JSAN>, so please refer to
its documentation for additional details.

=head1 DIFFERENCES

=over 4

=item 1 ./Build install

This action will install current distribution in your local JSAN library. See below for details.

=item 2 ./Build docs

This action will build a documentation files for this distribution. Default markup for documentation is POD. Alternative markup 
can be specified with C<docs_markup> configuration parameter (see Synopsis). Currently supported markups: 'pod', 
'md' (Markdown via Text::Markdown), 'mmd' (MultiMarkdown via Text::MultiMarkdown). 

Resulting documentation files will be placed under B</docs> directory, categorized by the formats. For 'pod' markup there will be
/doc/html, /doc/pod and /doc/text directories. For 'md' and 'mmd' markups there will be /doc/html and /doc/[m]md directories.

For 'md' and 'mmd' markups, its possible to keep the module's documentation in separate file. The file should have the same name as module,
with extensions, changed to markup abbreviature. An example:

      /lib/Module/Name.js
      /lib/Module/Name.mmd
      

=item 3 ./Build task [--task_name=foo]

This action will build a specific concatenated version (task) of current distribution.
Default task name is B<'Core'>, task name can be specified with C<--task_name> command line option.

Information about tasks is stored in the B<Components.JS> file in the root of distribution.
See the Synposys for example of B<Components.JS>. 

After concatenation, resulting file is placed on the following path: B</lib/Task/Distribution/Name/SampleTask.js>, 
assuming the name of your distribution was B<Distribution.Name> and the task name was B<SampleTask>


=item 4 ./Build test

This action relies on not yet released JSAN::Prove module, stay tuned for further updates.

=back


=head1 LOCAL JSAN LIBRARY

This module uses concept of local JSAN library, which is organized in the same way as perl library.

The path to the library is resolved in the following order:

1. B<--install_base> command-line argument

2. environment variable B<JSAN_LIB>

3. Either the first directory in C<$Config{libspath}>, followed with C</jsan> (probably C</usr/local/lib> on linux systems)
or C<C:\JSAN> (on Windows)

As a convention, it is recommended, that you configure your local web-server
that way, that B</jsan> will point at the B</lib> subdirectory of your local
JSAN library. This way you can access any module from it, with URLs like:
B<'/jsan/Test/Run.js'>  



=head1 STATIC FILES HANDLING

Under static files we'll assume any files other than javascript (*.js). Typically those are *.css files and images (*.jpg, *.gif, *.png etc).

All such files should be placed in the "static" directory. Default name for share directory is B<'/static'>. 
Alternative name can be specified with C<static_dir> configuration parameter (see Synopsis). Static directory can be organized in any way you prefere.

Lets assume you have the following distribution structure:

  /lib/Distribution/Name.js
  /static/css/style1.css 
  /static/img/image1.png

After building (B<./Build>) it will be processed as:

  /blib/lib/Distribution/Name.js
  /blib/lib/Distribution/Name/static/css/style1.css 
  /blib/lib/Distribution/Name/static/img/image1.png

During installation (B<./Build install>) the whole 'blib' tree along with static files will be installed in your local library.


=head1 AUTHOR

Nickolay Platonov, C<< <nplatonov at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-module-build-jsan-installable at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-Build-JSAN-Installable>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SEE ALSO

=over

=item Examples of installable JSAN distributions 

L<http://github.com/SamuraiJack/JooseX-Namespace-Depended/tree>

L<http://github.com/SamuraiJack/joosex-bridge-ext/tree>

=item L<http://www.openjsan.org/>

Home of the JavaScript Archive Network.

=item L<http://code.google.com/p/joose-js/>

Joose - Moose for JavaScript

=item L<http://github.com/SamuraiJack/test.run/tree>

Yet another testing platform for JavaScript

=back

=head1 SUPPORT

This module is stored in an open repository at the following address:

L<http://github.com/SamuraiJack/Module-Build-JSAN-Installable/tree/>


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Build-JSAN-Installable>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Module-Build-JSAN-Installable>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Module-Build-JSAN-Installable>

=item * Search CPAN

L<http://search.cpan.org/dist/Module-Build-JSAN-Installable/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to David Wheeler for his excelent Module::Build::JSAN, on top of which this module is built.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Nickolay Platonov, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut


