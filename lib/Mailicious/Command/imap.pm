package Mailicious::Command::imap;
use Mojo::Base 'Mojolicious::Command';
use Mailicious::Model::Mail;
use Carp qw/ croak/;

has description => "IMAP commands to check server.\n";
has usage       => "usage: $0 imap <capabilities>\n";

sub run {
  my $self = shift;
  my $command = shift || '';

  print $self->usage if ($command eq '');

  unless ($self->app->config->{imap}) {
    croak "Mailicious not configured for imap";
  }

  if ($command eq 'capabilities') {
    return $self->capabilities();
  }
}

sub capabilities {
  my $self = shift;

  my $config      = $self->app->config;
  my $server_name = $config->{imap}->{server};

  say "Capabilities of server $server_name:";

  my $result = $self->app->model->get_capabilities();

  foreach my $c (@{$result}) {
    say " * $c";
  }
}

1;
