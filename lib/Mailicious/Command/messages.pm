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

  foreach my $m (@{$result->{messages}}) {
    print <<TXT
 $m->{from}->{name} ... $m->{subject}
TXT
  }
}

1;
