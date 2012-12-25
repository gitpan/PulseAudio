package PulseAudio::Module;
use strict;
use warnings;

use constant _CAT => 'module';

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

__PACKAGE__->meta->make_immutable;
