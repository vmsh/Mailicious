package Mailicious::Message;
use Mojo::Base 'Mojolicious::Controller';
use Mailicious::Model::Mail;

# Show an e-mail message
sub show {
  my $self = shift;

  my $folder  = $self->param('folder');
  my $message = $self->param('message');

  my $model = $self->app->model;

  my $result = $model->message($folder, $message);

  $self->stash(
    subject => 'Foobar',
    header  => $result->{'BODY[HEADER]'},
    body    => $result->{'BODY[TEXT]'},
  );
}

1;

