package Dist::Zilla::Plugin::JSAN::NPM::Publish;

# ABSTRACT: Publish your module in npm with `dzil release`  

use Moose;

with 'Dist::Zilla::Role::Releaser';

use Path::Class;



#================================================================================================================================================================================================================================================
sub release {
    my ($self, $archive) = @_;
    
    
    $self->log(`npm publish $arhive`);
}




no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);


1;


=head1 SYNOPSIS

In your F<dist.ini>:

    [JSAN::NPM::Publish]
    

=head1 DESCRIPTION

This plugin will just call `npm publish <tarball>` during `dzil release`.


=cut
