package Mailicious::Mail;
use Mojo::Base 'Mojolicious::Controller';
use Mailicious::Model::Mail;

has model => sub {
  my $self = shift;

  my $model = Mailicious::Model::Mail->new();

  return $model;
};

# List folders
sub index {
  my $self   = shift;

  my $folder = $self->param('folder') || 'INBOX';

  my $result = $self->model->get($folder);
  my $folders = $self->model->get_folders();

  $self->stash(
    folders        => $folders,
    folder         => $result->{folder},
    messages       => $result->{messages},
    no_of_messages => $result->{no_of_messages},
  );
}

1;
