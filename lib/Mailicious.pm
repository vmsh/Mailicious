package Mailicious;
use Mojo::Base 'Mojolicious';
use Mailicious::Model::Mail;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $config = $self->plugin('Config');

  $self->setup_model;

  # Add custom commands
  push @{$self->commands->namespaces}, 'Mailicious::Command';

  # Router
  my $r = $self->routes;

  $r->get('/')->to('folder#index');
  $r->get('/folder/#folder')->name('folder')->to('folder#show');
  $r->get('/folder/#folder/:page')->name('folder_page')->to('folder#show');
  $r->get('/message/#folder/#message')->name('message')->to('message#show');

  # Default stash
  $self->defaults(
    layout  => 'default',
    folders => [$self->model->get_folders]
  );

  # Helpers
  $self->helper(
    nl2br => sub {
      shift;
      my $string = shift;

      $string =~ s/\n/<br>/g;

      return $string;
    }
  );
}

sub setup_model {
  my $self = shift;

  my $model = Mailicious::Model::Mail->new(
    {
      server => $self->config->{imap}->{server},
      user   => $self->config->{imap}->{user},
      pass   => $self->config->{imap}->{pass},
      ssl    => $self->config->{imap}->{ssl},
      port   => $self->config->{imap}->{port},
    }
  );

  $self->helper(model => sub {$model});
}

1;
