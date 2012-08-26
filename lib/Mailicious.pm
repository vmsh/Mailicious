package Mailicious;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  my $config = $self->plugin('Config');

  # Router
  my $r = $self->routes;

  $r->get('/')->to('mail#index');
}

1;
