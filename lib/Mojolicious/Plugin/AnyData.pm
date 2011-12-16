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
__END__

=head1 NAME

Mojolicious::Plugin::AnyData

=head1 VERSION

version 1.0

=head1 DESCRIPTION

Mojolicious::Plugin::AnyData — using your perl-data in memory like a database source.

=head1 SYNOPSIS

    use Mojolicious::Plugin::AnyData
    
    sub startup {
	my $self = shift;
	
	$self->plugin(any_data => {
	    load_data => {
                cars => [
		    ['id', 'model'],
		    [ 1, 'Honda'], ],
		},
	    },
	    helper => 'dbh',
	});
	
	# ... or
	$self->plugin(any_data => {
	    func => ['cars', 'XML', 'cars.xml', 'ad_import'],
	});
    }

=head1 CONFIGURATION

There is no need to required option, you can load data in every moment in
your code, and helper turns to default value 'dbh' if not specified.

You can change DBD::AnyData instance to your production database handler,
just by changing a development mode to production in your project:

    app->mode('production');

=head1 METHOD/HELPERS

A helper will be created with your specified name or 'dbh' by default.

=head1 SEE ALSO

Mojolicious, DBI, DBD::AnyData

=head1 AUTHOR

Alexander Ponomarev, C<< <shootnix@gmail.com> >>

=head1 BUGS/CONTRIBUTING

Please report any bugs or feature requests to through the web interface
at L<https://github.com/shootnix/Mojolicious-Plugin-AnyData/issues>.
If you want to contribute changes or otherwise involve yourself in development,
feel free to fork the Git repository from
L<https://github.com/shootnix/Mojolicious-Plugin-AnyData/>.


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    