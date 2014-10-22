package PulseAudio;
use strict;
use warnings;

use Moose;
use v5.10;

with 'PulseAudio::Backend::Utilities';

has 'pulse_server' => (
	isa         => 'Str'
	, is        => 'ro'
	, required  => 0
	, predicate => '_has_pulse_server'
);

our $VERSION = '0.03';

sub exec {
	my ( $self, $hash ) = @_; 
	local $ENV{PATH} = undef;
	my @env_args = grep defined, (
		(
			$self->_has_pulse_server
			? sprintf("PULSE_SERVER=%s", $self->pulse_server)
			: undef
		)
		, sprintf("PULSE_SINK=%s", $hash->{sink}->index)
		, sprintf("PULSE_SOURCE=%s", $hash->{source}->index)
	);
	system(
		'/usr/bin/env'
		, @env_args
		, $hash->{prog}
		, @{ $hash->{args} }
	);
}

__PACKAGE__->meta->make_immutable;


__END__

=head1 NAME

PulseAudio - An object oriented interface to pacmd.

=head1 DESCRIPTION

This is a suite of tools that should make scripting PulseAudio simplier. Please
see further docs in L<PulseAudio::Backend::Utilities>, L<PulseAudio::Sink>,
L<PulseAudio::Source>.

=head1 SYNOPSIS

This module provides an object oriented interface into the Pulse configuration L<pacmd>.

	use PulseAudio;
	my $pa = PulseAudio->new;

	my $pa = PulseAudio->new( pulse_server => '192.168.1.102' );

	## We because the absolute location of the key is {properties}{device.bus_path}
	my $sink = $pa->get_sinks_by( ['properties', 'device.bus_path'], 'pci-0000:00:1b.0' )
  $sink = $pa->get_sink_by_index(5);
  
  $sink = $pa->get_sink_by([qw/properties device.bus_path/], q[pci-0000:00:1b.0] );
  
  $sink->set_sink_volume('50%');
  
	# Execute VLC with the B<PULSE_SINK> environmental variable set the sink's index.
	$sink->exec( '/usr/bin/vlc' );

	$pa->exec(
		sink => $sink
		, source => $source
		, prog => '/usr/bin/vlc'
		, args => ['foo.mp3']
	);

	# Set the sinks's volume
	$sink->set_sink_volume( 0x10000 ); # Sets volume to max;
	$sink->set_sink_volume( 'MAX' ); # Sets volume to max;

=head1 METHODS

The get_by methods take an array ref and a value and return the first object. The array-ref corresponds to the depth and location of the value to check against. See the L<SYNOPSIS> for an example.

=over 4

=item get_card_by( $arrayRef, $value )

=item get_sink_by( $arrayRef, $value )

=item get_source_by( $arrayRef, $value )

=item get_source_output_by( $arrayRef, $value )

=item get_sink_input_by( $arrayRef, $value )

=item get_sample_by( $arrayRef, $value )

=item get_client_by( $arrayRef, $value )

=item get_module_by( $arrayRef, $value )

=back

Retreive the default.

=over 4

=item get_default_sink()

=item get_default_source()

=back

Return the specific requested object by unique id (index or name in the case of Samples).

=over 4

=item get_card_by_index( $idx )

=item get_sink_by_index( $idx )

=item get_source_by_index( $idx )

=item get_source_output_by_index( $idx )

=item get_sink_input_by_index( $idx )

=item get_sample_by_name( $name )

=item get_client_by_index( $idx )

=item get_module_by_index( $idx )

=back

=head1 SEE ALSO

B<DO READ>: L<Commands> (doc/Commands.pod)

=over 4

=item L<PulseAudio::Backend::Utilities>

=item L<PulseAudio::Sink>

=item L<PulseAudio::Source>

=item L<PulseAudio::SinkInput>

=item L<PulseAudio::SourceOutput>

=item L<PulseAudio::Module>

=item L<PulseAudio::Sample>

=item L<PulseAudio::Client>

=item L<PulseAudio::Card>

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PulseAudio


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PulseAudio>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PulseAudio>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PulseAudio>

=item * Search CPAN

L<http://search.cpan.org/dist/PulseAudio/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Evan Carroll.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of PulseAudio
