package PulseAudio::Source;
use strict;
use warnings;
use autodie;

use constant _CAT => 'source';

use PulseAudio::Backend::Utilities;

use Moose;

use PulseAudio::Types qw(PA_Index);

has 'index' => ( isa => PA_Index, is => 'ro', required => 1 );

has '_dump' => (
	isa        => 'HashRef'
	, is       => 'ro'
	, required => 1
	, init_arg => 'dump'
	, traits   => ['Hash']

	, handles  => {
		'get' => 'get'
	}
);

foreach my $cmd ( @{_commands()} ) {
	__PACKAGE__->meta->add_method( $cmd->{alias} => $cmd->{sub} );
}

sub _commands {
	PulseAudio::Backend::Utilities->_pacmd_help->{catagory}{ _CAT() };
}

sub exec {
	my ( $self, $prog, @args ) = @_; 
	local $ENV{PATH} = undef;
	system(
		'/usr/bin/env'
		, '-'
		, sprintf("PULSE_SERVER=%s PULSE_SOURCE=%s", $self->pulse_server, $self->index)
		, $prog
		, @args
	);
}

__PACKAGE__->meta->make_immutable;
