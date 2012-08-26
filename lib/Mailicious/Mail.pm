package Mailicious::Mail;
use Mojo::Base 'Mojolicious::Controller';
use Mailicious::Model::Mail;

# List folders
sub index {
  my $self = shift;

  my $folder = $self->param('folder') || 'INBOX';

  my $model = $self->app->model;

  my $result  = $model->get($folder);
  my $folders = $model->get_folders();

  $self->stash(
    folders        => $folders,
    folder         => $result->{folder},
    messages       => $result->{messages},
    no_of_messages => $result->{no_of_messages},
  );
}

1;
