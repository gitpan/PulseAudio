package PulseAudio::Sink;
use strict;
use warnings;
use autodie;

use constant _CAT => 'sink';

use PulseAudio::Backend::Utilities;

use Moose;

with 'PulseAudio::Roles::Object';

use PulseAudio::Types qw(PA_Index);
has 'index' => ( isa => PA_Index, is => 'ro', required => 1 );

foreach my $cmd ( @{_commands()} ) {
	__PACKAGE__->meta->add_method( $cmd->{alias} => $cmd->{sub} );
}

sub _commands {
	PulseAudio::Backend::Utilities->_pacmd_help->{catagory}{ _CAT() };
}

sub exec {
	my ( $self, $prog, @args ) = @_; 
	local $ENV{PATH} = undef;
	my @env_args = grep defined, (
		(
			$self->server->_has_pulse_server
			? sprintf("PULSE_SERVER=%s", $self->server->pulse_server)
			: undef
		)
		, sprintf("PULSE_SINK=%s", $self->index)
	);
	system(
		'/usr/bin/env'
		, @env_args
		, $prog
		, @args
	);
}

__PACKAGE__->meta->make_immutable;
