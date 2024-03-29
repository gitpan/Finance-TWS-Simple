package Finance::TWS::Simple;

# ABSTRACT: simple InteractiveBrokers API (blocking abstraction over AnyEvent::TWS)

use strict;
use warnings;

use AnyEvent;
use AnyEvent::TWS;


sub new {
    my ($class, %arg) = @_;

    my $self = bless {}, $class;

    # connect to TWS
    $self->{tws} = AnyEvent::TWS->new(%arg);
    $self->{tws}->connect->recv;

    return $self;
}

sub next_id { (shift)->{tws}->next_valid_id }

sub ae_call {
   my ($self, $object, $request) = @_;

   $self->{tws}->call($request, sub { $object->cb(shift) });
}

sub call {
    my ($self, $name, $arg) = @_;

    my $cv    = AE::cv;
    my $class = 'Finance::TWS::Simple::' . $name;
    eval "use $class"; die $@ if $@;
    $class->call($self, $cv, $arg);

    return $cv->recv;
}

sub struct  { return (shift)->{tws}->struct(@_)  }
sub request { return (shift)->{tws}->request(@_) }

1;


__END__
=pod

=head1 NAME

Finance::TWS::Simple - simple InteractiveBrokers API (blocking abstraction over AnyEvent::TWS)

=head1 VERSION

version 0.000_01

=head1 SYNOPSIS

  use Data::Dumper;
  use Finance::TWS::Simple;

  my $tws = Finance::TWS::Simple->new;

  my $contract = $tws->struct(Contract => {
      symbol      => 'EUR',
      secType     => 'CASH',
      exchange    => 'IDEALPRO',
      localSymbol => 'EUR.USD',
  });
  my $details = $tws->call(ContractDetails => {contract => $contract});

  warn Dumper $details;

=head1 DESCRIPTION

A simple, blocking layer above L<AnyEvent::TWS> and L<Protocol::TWS> to
access InteractiveBrokers Traders Workstation (TWS) API.

Use it in simple scripts, e. g. to retrieve historical data.

=head1 CONSTRUCTOR

=head2 new

Constructor, connects to InteractiveBrokers API. Accepts the same
parameters as L<AnyEvent::TWS-E<gt>new|AnyEvent::TWS/new>
(host, port and client_id - all have useful defaults).

=head1 METHODS

=head2 call

Calls an (abstracted) API function. First parameter name (equals class name
of subclass), second parameter (hashref) arguments.

Have a look at the other classes in this distribution to know which function
calls are available:

=over

=item L<Finance::TWS::Simple::ContractDetails>

=item L<Finance::TWS::Simple::HistoricalData>

=back

At the moment the abstractions are quite limited, email me your suggestions.

=head2 struct

Shortcut for instanciating L<Protocol::TWS::Struct> subclasses. First
parameter name (equals class name), second parameter (hashref) arguments
to the constructor.

=head1 INTERNAL METHODS

Not really internal, you may use them. But normally you don't have to.
These are used from the subclasses.

=head2 next_id

Returns the next (unused) request ID (see
L<AnyEvent::TWS-E<gt>next_valid_id|AnyEvent::TWS/next_valid_id>).

=head2 ae_call

Shortcut to L<AnyEvent::TWS-E<gt>call|AnyEvent::TWS/call>. First parameter
is an object (which implements C<cb> method), second parameter is
L<Protocol::TWS::Request> object. The response is handed to the C<cb>
method.

=head2 request

Shortcut for instanciating L<Protocol::TWS::Request> subclasses. First
parameter name (equals class name), second parameter (hashref) arguments
to the constructor.

=head1 BUGS AND SUPPORT

Bugs are quite likely, as I did not try all requests/responses. If you find a
bug, please email me a code example together with a description what you expect
as result.

If you have any questions or suggestions feel free to email me as well. There
are a lot of abstractions missing.

Also, if you have any examples that I can include, I would appreciate it.

=head1 SEE ALSO

L<http://www.interactivebrokers.com/en/p.php?f=programInterface>,
L<http://www.interactivebrokers.com/php/apiUsersGuide/apiguide.htm#apiguide/c/c.htm>,
L<Protocol::TWS>, L<AnyEvent::TWS>

=head1 AUTHOR

Uwe Voelker <uwe@uwevoelker.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Uwe Voelker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

