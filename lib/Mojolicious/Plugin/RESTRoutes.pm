use Modern::Perl '2012'; # strict, warnings etc.;
package Mojolicious::Plugin::RESTRoutes;
# ABSTRACT: routing helpers for RESTful operations
our $VERSION = '0.0100062'; # TRIAL VERSION

use Mojo::Base 'Mojolicious::Plugin';


use Lingua::EN::Inflect 1.895 qw/PL/;

sub register {
	my ($self, $app) = @_;
	
	# For the following TODOs also see http://pastebin.com/R9zXrtCg
	# TODO Add GET /api/users/new            --> rest_create_user_form
	# TODO Add GET /api/users/:userid/edit   --> rest_edit_user_form
	# TODO Add GET /api/users/:userid/delete --> rest_delete_user_form
	# TODO Add GET /api/users/search         --> rest_search_user_form
	# TODO Add PUT /api/users/search/:term   --> rest_search_user_form (submit/execution)
	$app->routes->add_shortcut(
		rest_routes => sub {
			my $r = shift;
			my $params = { @_ ? (ref $_[0] ? %{ $_[0] } : @_) : () };

			my $name = $params->{name};
			my $readonly = $params->{readonly} || 0;
			my $controller = $params->{controller} || "$name#";
			
			my $plural = PL($name, 10);

			$app->log->debug("Creating routes for resource '$name' (controller: $controller)");
			
			#
			# Generate "/$name" route, handled by controller $name
			#
			my $resource = $r->route("/$plural")->to($controller);
	
			# GET requests - lists the collection of this resource
			$resource->get->to('#rest_list')->name("list_$plural");
			$app->log->info("Created route    GET ".$r->to_string."/$plural   (rest_list)");
	
			if (!$readonly) {
				# POST requests - creates a new resource
				$resource->post->to('#rest_create')->name("create_$name");
				$app->log->info("Created route   POST ".$r->to_string."/$plural   (rest_create)");
			};
			
			#
			# Generate "/$name/:id" route, also handled by controller $name
			#

			# resource routes might be chained, so we need to define an
			# individual id and pass its name to the controller (idname)
			$resource = $r->route("/$plural/:${name}id", "${name}id" => qr/\d+/)->to($controller, idname => "${name}id");
			
			# GET requests - lists a single resource
			$resource->get->to('#rest_show')->name("show_$name");
			$app->log->info("Created route    GET ".$r->to_string."/$plural/:${name}id   (rest_show)");
			
			if (!$readonly) {
				# DELETE requests - deletes a resource
				$resource->delete->to('#rest_remove')->name("delete_$name");
				$app->log->info("Created route DELETE ".$r->to_string."/$plural/:${name}id   (rest_delete)");
				
				# PUT requests - updates a resource
				$resource->put->to('#rest_update')->name("update_$name");
				$app->log->info("Created route    PUT ".$r->to_string."/$plural/:${name}id   (rest_update)");
			}	 
			
			# return "/$name/:id" route so that potential child routes make sense
			return $resource;
		}
	);
}

1;

__END__

=pod

=head1 NAME

Mojolicious::Plugin::RESTRoutes - routing helpers for RESTful operations

=head1 VERSION

version 0.0100062

=head1 DESCRIPTION

This Mojolicious plugin adds some routing helpers for
L<REST|http://en.wikipedia.org/wiki/Representational_state_transfer>ful
L<CRUD|http://en.wikipedia.org/wiki/Create,_read,_update_and_delete>
operations via HTTP to the app.

The routes are intended, but not restricted to be used by AJAX applications.

=head1 EXTENDS

=over 4

=item * L<Mojolicious::Plugin>

=back

=head1 METHODS

=head2 register

Adds the routing helpers. Is called by Mojolicious. 

=head1 MOJOLICIOUS SHORTCUTS

=head2 rest_routes

Can be used to easily generate the needed RESTful routes for a resource.

	$self->rest_routes(name => 'user');

	# Installs the following routes (given that $r->namespaces == ['My::Mojo']):
	#    GET /api/users         --> My::Mojo::User::rest_list()
	#   POST /api/users         --> My::Mojo::User::rest_create()
	#    GET /api/users/:userid --> My::Mojo::User::rest_show()
	#    PUT /api/users/:userid --> My::Mojo::User::rest_update()
	# DELETE /api/users/:userid --> My::Mojo::User::rest_remove()

The target controller has to implement the following methods:

=over 4

=item *

rest_list

=item *

rest_create

=item *

rest_show

=item *

rest_update

=item *

rest_remove

=back

There are some options to control the route creation:

B<Parameters>

=over

=item name

The name of the resource, e.g. a "user", a "book" etc. This name will be used to
build the route URL as well as the controller name (see example above).

=item readonly

(optional) if set to 1, no create/update/delete routes will be created

=item controller

Default behaviour is to use the resource name to build the CamelCase controller
name (this is done by L<Mojolicious::Routes::Route>). You can change this by
directly specifying the controller's name via the I<controller> attribute.

Note that you have to give the real controller class name (i.e. CamelCased or
whatever you class name looks like) including the full namespace.

	$self->rest_routes(name => 'user', controller => 'My::Mojo::Person');

	# Installs the following routes:
	#    GET /api/users         --> My::Mojo::Person::rest_list()
	#    ...

=back

=encoding utf8

=head1 AUTHOR

Jens Berthold <cpan-mp-restroutes@jebecs.de>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jens Berthold.

This is free software, licensed under:

  The MIT (X11) License

=cut
