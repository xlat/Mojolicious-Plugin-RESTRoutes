#!/usr/bin/perl -w
#
# Aufruf: morbo ./testdoc.pl
#
use 5.14.2;
use strict;
use warnings;
use utf8;

use Mojolicious::Lite;
use lib 'Mojolicious-Plugin-CRUDRoutes-0.0000038/lib';

# Plugin zur Anzeige der PerlDoc-Dokumentation im Webbrowser unter /perldoc.
plugin 'PODRenderer';

# Programminitialisierung
my $app = app;

app->secret('dummy');
app->start;

# Starten des Browsers
print "Launching browser...\n";
system "x-www-browser", "http://localhost:3000/perldoc/Mojolicious::Plugin::CRUDRoutes";

return $app;
