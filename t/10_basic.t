use Test::More;# tests => 14;
use Test::Mojo;
use lib 'lib/';

use Mojolicious::Plugin::RESTRoutes;

#
# Test controller with target methods
#
package Ive::Lost::My::Mojo::User;
use Mojo::Base 'Mojolicious::Controller';
sub catchall {
	my ($self, $msg) = @_; 
	return $self->render(text => "$msg:".($self->param($self->param('idname')) || ''));
}
sub rest_list   { shift->catchall('list');   }
sub rest_create { shift->catchall('create'); }
sub rest_show   { shift->catchall('show');   }
sub rest_update { shift->catchall('update'); }
sub rest_remove { shift->catchall('remove'); }

#
# Test Mojolicious app
#
package Test::Mojolicious::Plugin::RESTRoutes;
use Mojo::Base 'Mojolicious';

sub startup {
	my $self = shift;
	$self->secrets(["Victorias Secret"]);

	#$self->log( MojoX::Log::Log4perl->new() );

	my $public = $self->routes;
	$public->namespaces(['Ive::Lost::My::Mojo']);

	#
	# REST routes
	#
	$self->plugin('RESTRoutes');
	my $rt_api = $public->route('/api');
	# /api/users/
	$rt_api->rest_routes(name =>  'user');
	# /api/systems/
	my $rt_fw = $rt_api->rest_routes(name => 'system', readonly => 1, controller => 'Ive::Lost::My::Mojo::User');
		# /api/systems/xx/changes
		$rt_fw->rest_routes(name => 'change', readonly => 1, controller => 'Ive::Lost::My::Mojo::User');
}

#
# Main test script
#
package main;

my $t = Test::Mojo->new('Test::Mojolicious::Plugin::RESTRoutes');

# users
$t->get_ok('/api/users')->status_is(200)->content_is('list:');
$t->post_ok('/api/users')->status_is(200)->content_is('create:');
$t->get_ok('/api/users/5')->status_is(200)->content_is('show:5');
$t->put_ok('/api/users/5')->status_is(200)->content_is('update:5');
$t->put_ok('/api/users')->status_is(404);
$t->delete_ok('/api/users/5')->status_is(200)->content_is('remove:5');
$t->delete_ok('/api/users')->status_is(404);

# systems
$t->get_ok('/api/systems')->status_is(200)->content_is('list:');
$t->post_ok('/api/systems')->status_is(404);
$t->get_ok('/api/systems/5')->status_is(200)->content_is('show:5');
$t->put_ok('/api/systems/5')->status_is(404);
$t->delete_ok('/api/systems/5')->status_is(404);

# systems/changes
$t->get_ok('/api/systems/changes')->status_is(404);
$t->get_ok('/api/systems/5/changes')->status_is(200)->content_is('list:5');
$t->post_ok('/api/systems/5/changes')->status_is(404);
$t->get_ok('/api/systems/5/changes/3')->status_is(200)->content_is('show:3');
$t->put_ok('/api/systems/5/changes/3')->status_is(404);
$t->delete_ok('/api/systems/5/changes/3')->status_is(404);

done_testing();
