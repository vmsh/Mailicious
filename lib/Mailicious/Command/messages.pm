package Mailicious::Command::messages;
use Mojo::Base 'Mojolicious::Command';
use Mailicious::Model::Mail;

has description => "List messages.\n";
has usage       => "usage: $0 imap <list <folder>>\n";

sub run {
  my $self    = shift;
  my $command = shift || '';
  my @args    = @_;

  print $self->usage if ($command eq '');

  if ($command eq 'list') {
    return $self->list(@args);
  }
}

sub list {
  my $self   = shift;
  my $folder = shift;

  my $result = $self->app->model->get($folder);

  say "Messages:";

  my $from;
  foreach my $m (@{$result->{messages}}) {
    $from = $m->{from}->{full};

    $from = $m->{from}->{name}
      if ($m->{from}->{name});

    print <<TXT
 $from ... $m->{subject}
TXT
  }
}

1;
