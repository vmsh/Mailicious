package Mailicious::Folder;
use Mojo::Base 'Mojolicious::Controller';
use Mailicious::Model::Mail;

# By default, list content in INBOX
sub index {
  my $self = shift;

  $self->redirect_to('folder', folder => 'INBOX');
}

# List folders
sub show {
  my $self = shift;

  my $folder = $self->param('folder');

  my $model = $self->app->model;

  my $result = $model->get($folder);

  $self->stash(
    folder        => $result->{folder},
    folder_status => $result->{folder_status},
    messages      => $result->{messages},
  );
}

1;
