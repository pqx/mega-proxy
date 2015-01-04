#!/usr/bin/env perl

use Mojolicious::Lite;
use Net::MEGA;
use Cache::Memcached::Sweet;
use File::Temp 'tempfile';
use File::Spec::Functions;
use File::MimeInfo::Magic;
use File::Basename qw(dirname);
use Session::Token;
use File::Path 'make_path';
my $mega = new Net::MEGA();

my $cache = "/tmp/mega-proxy-$$/";

mkdir($cache) unless -d $cache;
push @{ app->static->paths }, $cache;

get '*file' => sub {
    my $self = shift;
    my $file = $self->param('file');

    if (!$file || $file=~m|/$|) {
    	my @listing = $mega->ls($file);
   	    return $self->render(template=>"listing", file=>$file, files=>[@listing]);
    } else { 	
    	my $cachedfn = catfile($cache, $file);
    	if (-f $cachedfn) {
			return $self->reply->static($cachedfn);
    	}

    	my $dn = dirname($cachedfn);
    	if (!-d $dn) {
    		make_path($dn);
    	}
    	$mega->get($file, $cachedfn);
    	if(-f $cachedfn) {
			return $self->reply->static($file);
		} else {
			return $self->reply->not_found();
		}
    }
  
};





#app->config(hypnotoad => {listen => ['http://*:8448'], proxy=>1,  workers=>6, pid_file => '/tmp/hypnotoad_megaproxy.pid'});
app->start;
__DATA__


@@ listing.html.ep
<html>
	<head>
	<title><%= $file %></title>
	</head>
	<body>
	<h1><%= $file %></h1>
	<hr>
	<table>
	% foreach my $f (@$files) {
	<tr>
		<td>
			% if($f->{path} eq $file) {
			% } elsif ($f->{is_dir}) {
				<a href="<%= $f->{filename} %>/"><%= $f->{filename} %>/</a>
			% } else {
				<a href="<%= $f->{filename} %>"><%= $f->{filename} %></a>
			% }
		</td>
		<td><%= $f->{size} %></td>
		<td><%= $f->{time} %></td>
	</tr>
	% }
	</table>
	</body>
</html>

