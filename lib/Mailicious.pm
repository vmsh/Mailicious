package Mailicious;
use Mojo::Base 'Mojolicious';
use Mailicious::Model::Mail;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $config = $self->plugin('Config');

  $self->setup_model;

  # Router
  my $r = $self->routes;

  $r->get('/')->to('mail#index');
}

sub setup_model {
  my $self = shift;

  my $model = Mailicious::Model::Mail->new();

  $self->helper(model => sub { $model });
}

1;
