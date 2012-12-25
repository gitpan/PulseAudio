package PulseAudio::Roles::CLI;
use Moose::Role;
use feature ':5.10';
use strict;
use warnings;

use PulseAudio::Types qw();
our $db = command_db();

has '_commands' => (
	isa       => 'HashRef'
	, is      => 'ro'
	, traits  => ['Hash']
	, handles => {
		'GET_RAw' => 'get'
	}
	, default => sub {$db}
);
	
sub command_db {

	return $db if defined $db;

	open( my $fh , '-|', 'pacmd', 'help' );
	my %db;

	while ( my $line = $fh->getline ) {
		chomp $line;
		next unless $line =~ /^ \s+ ([a-z-]+) \s+ (.*)/x;
		my ( $name, $desc ) = ( $1, $2 );

		my $alias = $name;
		$alias =~ tr/-/_/;

		my @func_sig;
		if ( $desc =~ /\(args?: (.*)\)/ ) {
			@func_sig = split /, */, $1;
		};

		my $cat;
		given ( $name ) {
			when ( qr/list-/ ) { $cat = 'list' }
			when ( qr/source/ ) { $cat = 'source' }
			when ( qr/sink/ ) { $cat = 'sink' }
			default {
				given ( @func_sig ) {
					when ( qr/sink/ ) { $cat = 'sink' }
					default { $cat = 'misc'; }
				}
			}
		};

		my $sub;
		if ( $cat eq 'misc' ) {
			$sub = sub { die 'Not supported' };
		}
		elsif ( $cat eq 'list' ) {

			$sub = sub {
				my $self = shift;
				my $info = $self->_info;
				$alias =~ /list[-_](.*)s/;
				if ( exists $info->{$1} ) {
					return $info->{$1};
				}
				else {
					Carp::croak "Command [$1] is not supported\n";
				}
			};

		}
		elsif ( @func_sig && $func_sig[0] ~~ qr/index/ ) {

			$sub = sub {
				my ( $self, @args ) = @_;
				unshift @args, $self;
				_coerce_and_test_function_types( \@args, \@func_sig );
				_exec( $name, @args );
				$self;
			}

		}
		elsif ( @func_sig && $func_sig[-1] ~~ qr/index/ ) {
			$sub = sub {
				my ( $self, @args ) = @_;
				push @args, $self;
				_coerce_and_test_function_types( \@args, \@func_sig );
				_exec( $name, @args );
				$self;
			}
		}
		else { warn "$line is not supported" }
		
		my $cmd = $db{commands}{$alias} = {
			desc => $desc
			, args => @func_sig?\@func_sig:undef
			, name => $name
			, sub  => $sub
			, alias => $alias
		};
		push @{ $db{catagory}{$cat} }, $cmd;

	}

	\%db;
}

use autodie;
use IPC::Run3;
sub _exec {
	say "EXEC: @_" if $ENV{DEBUG};

	my ($out, $err);
	IPC::Run3::run3( ['pacmd', @_], \undef, \$out, \$err ) or die;

	if ( $ENV{DEBUG} ) {
		tr/\r\n>//d for $out, $err;
		say "\t STDOUT: $out";
		say "\t STDERR: $err";
	}

	die $err if $err;

}

## A simple helper function that takes an arguments, and an array of types and
## tries to coerce the arguments to the types.
sub _coerce_and_test_function_types {
	my ( $argRef, $typeRef ) = @_;
	
	warn 'Not enough arguments passed'
		if scalar @$argRef != scalar @$typeRef
	;
	
	my $count = 0;
	for ( @$argRef ) {
		given ( $typeRef->[$count] ) {
			when ( qr/index/ ) {
				$argRef->[$count] = PulseAudio::Types::to_PA_Index($argRef->[$count])
					unless PulseAudio::Types::is_PA_Index($argRef->[$count])
				;
			}
			when ( 'volume' ) {
				$argRef->[$count] = PulseAudio::Types::to_PA_Volume($argRef->[$count])
					unless PulseAudio::Types::is_PA_Volume($argRef->[$count])
				;
			}
			when ( 'bool' ) {
				$argRef->[$count] = PulseAudio::Types::to_PA_Bool($argRef->[$count])
					unless PulseAudio::Types::is_PA_Bool($argRef->[$count])
				;
			}
			when ( 'arguments' ) {
				Carp::croak 'Invalid argument, not a string'
					unless MooseX::Types::Moose::is_Str($argRef->[$count])
				;
				die;
			}
		};
		$count++;
	}

}

1;
