package Dist::Zilla::Plugin::JSAN::Bundle;

# ABSTRACT: Bundle the library files into "tasks", using information from Components.JS 

use Moose;

with 'Dist::Zilla::Role::FileGatherer';

use JSON 2;
use Module::Build::JSAN::Installable;
use Path::Class;


#================================================================================================================================================================================================================================================
sub gather_files {
    my $self = shift;
    
	my $components = file('Components.JS')->slurp;

	#removing // style comments
	$components =~ s!//.*$!!gm;

	#extracting from outermost {} brackets
	$components =~ m/(\{.*\})/s;
	$components = $1;

	my $deploys = decode_json $components;
	
	$self->concatenate_for_task($deploys, 'all');
}


#================================================================================================================================================================================================================================================
sub concatenate_for_task {
    my ($self, $deploys, $task_name) = @_;
    
    if ($task_name eq 'all') {
    	
    	foreach my $deploy (keys(%$deploys)) {
    		$self->concatenate_for_task($deploys, $deploy);  	
    	}
    
    } else {
	    my @components = $self->expand_task_entry($deploys, $task_name);
	    die "No components in task: [$task_name]" unless @components > 0;
	    
	    my @dist_dirs = split /-/, $self->zilla->name;
	    push @dist_dirs, $task_name;
	    $dist_dirs[-1] .= '.js';
	    
        $self->add_file(Dist::Zilla::File::FromCode->new({
            
            name => file('lib', 'Task', @dist_dirs) . '',
            
            code => sub {
        	    my $bundle_content = ''; 
        	    
        	    foreach my $comp (@components) {
        	        $bundle_content .= $self->get_component_content($comp) . ";\n";
        	    }
        	    
        	    return $bundle_content;
            }
        }));
    };
}


#================================================================================================================================================================================================================================================
sub expand_task_entry {
    my ($self, $deploys, $task_name, $seen) = @_;
    
    $seen = {} if !$seen;
    
    die "Recursive visit to task [$task_name] when expanding entries" if $seen->{ $task_name };
    
    $seen->{ $task_name } = 1; 
    
    return map { 
			
		/^\+(.+)/ ? $self->expand_task_entry($deploys, $1, $seen) : $_;
		
	} @{$deploys->{ $task_name }};    
}


#================================================================================================================================================================================================================================================
sub get_component_content {
    my ($self, $component) = @_;
    
    if ($component =~ /^jsan:(.+)/) {
        my @file = (Module::Build::JSAN::Installable->get_jsan_libroot, 'lib', split /\./, $1);
        $file[ -1 ] .= '.js';
        
        return file(@file)->slurp;
    } elsif ($component =~ /^=(.+)/) {
        return file($1)->slurp;
    } else {
        return $self->comp_to_filename($component)->slurp;
    } 
}


#================================================================================================================================================================================================================================================
sub comp_to_filename {
	my ($self, $comp) = @_;
	
    my @dirs = split /\./, $comp;
    $dirs[-1] .= '.js';
	
	return file('lib', @dirs);
}


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);


1;



=head1 SYNOPSIS

In your F<dist.ini>:

  [JSAN::Prereq]
  Foo.Bar       = 1.002
  MRO.Compat    = 10
  Sub.Exporter  = 0

=head1 DESCRIPTION

This module adds "fixed" prerequisites to your distribution.  These are prereqs
with a known, fixed minimum version that doens't change based on platform or
other conditions. 

The only difference from standard [Prereq] plugin is that this plugin
allows you to use the dot in the prereq name as the namespace delimeter.

=cut
