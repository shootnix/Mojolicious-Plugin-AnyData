#!/usr/bin/env perl
use strict;
use warnings;

# Disable IPv6, epoll and kqueue
BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More;

eval "use DBD::AnyData";
plan skip_all => 'DBD::AnyData required for this test!' if $@;
plan tests => 9;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;
use DBI;
use Try::Tiny;

plugin 'any_data', {
    load_data => {
	users => [
	    ['id_user', 'user_name'],
	    [1,         'Alex'],
	    [2,         'John'],
	]
    },
    helper => 'dbh',
};

get '/get-user' => sub {
    my $self = shift;
    
    my $user_name = $self->dbh->selectrow_array(qq{
	select user_name
	from users
	where
	    id_user = ?
    }, undef, 1);

    $self->render(text => ( $user_name eq 'Alex' ) ? 'ok' : 'failed');
};

get '/make-func' => sub {
    my $self = shift;
    
    $self->dbh->func('ages', 'ARRAY', [
            ['age', 'id_user'],
	    [28,    1],
	    [32,    2],
	],
	'ad_import'
    );
    
    $self->render(text => 'ok');
};

get '/get-age' => sub {
    my $self = shift;
    
    my $age = $self->dbh->selectrow_array(qq{
	select age
	from ages
	join users using (id_user)
	where
	    user_name = ?
    }, undef, 'Alex');
    
    $self->render(text => ($age == 28) ? 'ok' : 'failed');
};

my $t = Test::Mojo->new();

$t->get_ok('/get-user')->status_is(200)->content_is('ok');
$t->get_ok('/make-func')->status_is(200)->content_is('ok');
$t->get_ok('/get-age')->status_is(200)->content_is('ok');

