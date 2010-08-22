package Dist::Zilla::Plugin::JSAN::Bundle;

# ABSTRACT: Bundle the library files into "tasks", using information from Components.JS 

use Moose;

with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::FileMunger';

use Dist::Zilla::File::FromCode;

use JSON 2;
use Module::Build::JSAN::Installable;
use Path::Class;


#================================================================================================================================================================================================================================================
sub gather_files {
}


#================================================================================================================================================================================================================================================
sub munge_files {
    my $self = shift;
    
    return unless -f 'Components.JS';
    
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
    
    if ((ref $component eq 'HASH') && $component->{ text }) {
        
        return $component->{ text };
    
    } elsif ($component =~ /^jsan:(.+)/) {
        my @file = (Module::Build::JSAN::Installable->get_jsan_libroot, 'lib', split /\./, $1);
        $file[ -1 ] .= '.js';
        
        return file(@file)->slurp;
    } elsif ($component =~ /^=(.+)/) {
        return file($1)->slurp;
    } else {
        my $file_name = $self->comp_to_filename($component);
        
        my ($found) = grep { $_->name eq $file_name } (@{$self->zilla->files});
        
        return $found->content;
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

    [JSAN::Bundle]

In your F<Components.JS>:

    COMPONENTS = {
        
        "Core" : [
            "KiokuJS.Reference",
            
            "KiokuJS.Exception",
            "KiokuJS.Exception.Network",
            "KiokuJS.Exception.Format",
            "KiokuJS.Exception.Overwrite",
            "KiokuJS.Exception.Update",
            "KiokuJS.Exception.Remove",
            "KiokuJS.Exception.LookUp",
            "KiokuJS.Exception.Conflict"
        ],
        
        
        "Prereq" : [
            "=/home/cleverguy/js/some/file.js",
            "jsan:Task.Joose.Core",
            "jsan:Task.JooseX.Attribute.Bootstrap",
            
            "jsan:Task.JooseX.Namespace.Depended.NodeJS",
            
            "jsan:Task.JooseX.CPS.All",
            "jsan:Data.UUID",
            "jsan:Data.Visitor"
        ],
        
        
        "All" : [
            "+Core",
            "+Prereq"
        ]
    } 
    


=head1 DESCRIPTION

This plugins concatenates several source files into single bundle using the information from Components.JS file.

This files contains a simple JavaScript assignment (to allow inclusion via <script> tag) of the JSON structure.

First level entries of the JSON structure defines a bundles. Each bundle is an array of entries. 

Entry, starting with the "=" prefix denotes the file from the filesystem. 

Entry, starting with the "jsan:" prefix denotes the module from the jsan library. See L<Module::Build::JSAN::Installable>.

Entry, starting with the "+" prefix denotes the content of another bundle.

All other entries denotes the javascript files from the "lib" directory. For example entry "KiokuJS.Reference" will be fetched
as the content of the file "lib/KiokuJS/Reference.js"

All bundles are stored as "lib/Task/Distribution/Name/BundleName.js", assuming the name of the distrubution is "Distribution-Name"
and name of bundle - "BundleName".

=cut
