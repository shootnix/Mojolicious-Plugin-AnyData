package Mojolicious::Plugin::AnyData;
BEGIN {
    $Mojolicious::Plugin::AnyData::VERSION = '1.0';
}

use Mojo::Base 'Mojolicious::Plugin';

use DBI;

sub register {
    my ($self, $app, $param) = @_;
    
    return if $app->mode && $app->mode eq 'production';

    my $data   = $param->{load_data};
    my $func   = $param->{func};
    my $helper = $param->{helper};
    $helper ||= 'dbh';
    my $dbh  = DBI->connect('dbi:AnyData:(RaiseError=>1)');
    
    if ( $data && ref $data eq 'HASH' && keys %$data > 0 ) {
	for my $table_name ( keys %$data ) {
	    $dbh->func($table_name, 'ARRAY', $data->{$table_name}, 'ad_import');
        }
    }
    
    if ( $func && ref $func eq 'ARRAY' && scalar @$func > 0 ) {
	$dbh->func(@$func);
    }
    
    $app->helper( $param->{helper} => sub { return $dbh });
}

1;
