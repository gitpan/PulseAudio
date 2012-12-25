package PulseAudio;
use strict;
use warnings;

use Moose;
use v5.10;

with 'PulseAudio::Backend::Utilities';

has 'pulse_server' => (
	isa => 'Maybe[Str]'
	, is => 'ro'
	, required => 0
);

our $VERSION = '0.01';

__PACKAGE__->meta->make_immutable;


__END__

=head1 NAME

PulseAudio - The great new PulseAudio!

=head1 VERSION

Version 0.01_01

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

	# Execute VLC with the B<PULSE_SINK> environmental variable set the sink's index.
	$sink->exec( vlc );

	# Set the sinks's volume
	$sink->set_sink_volume( 0x10000 ); # Sets volume to max;
	$sink->set_sink_volume( 'MAX' ); # Sets volume to max;

=head1 SEE ALSO

=over 4

=item L<PulseAudio::Backend::Utilities>

=item L<PulseAudio::Sink>

=item L<PulseAudio::Source>

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


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Evan Carroll.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of PulseAudio
