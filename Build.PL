
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "MojoX::Log::Log4perl" => 0,
    "Test::Mojo" => 0,
    "Test::More" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "routing helpers for RESTful operations",
  "dist_author" => [
    "Jens Berthold <cpan-mp-restroutes\@jebecs.de>"
  ],
  "dist_name" => "Mojolicious-Plugin-RESTRoutes",
  "dist_version" => "0.0100062",
  "license" => "mit",
  "module_name" => "Mojolicious::Plugin::RESTRoutes",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Lingua::EN::Inflect" => "1.895",
    "Modern::Perl" => 0,
    "Mojo::Base" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
