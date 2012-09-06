package Mailicious::Model::Mail;
use Mojo::Base 'Mojolicious::Controller';
use Email::MIME::Encodings;
use Net::IMAP::Client;
use Carp qw/ croak/;

has imap => sub {
  my $self = shift;

  my $imap = Net::IMAP::Client->new(
    server => $self->{server},
    user   => $self->{user},
    pass   => $self->{pass},
    ssl    => $self->{ssl},
    port   => $self->{port}
  ) or croak "Could not connect to IMAP server";

  $imap->login or croak('Login failed: ' . $imap->last_error);

  return $imap;
};

sub get_folders {
  my $self = shift;

  return $self->imap->folders;
}

sub get {
  my $self = shift;
  my $folder = shift || 'INBOX';

  $self->imap->select($folder);

  my $imap_status = $self->imap->status($folder);
  my $status = {};

  $status->{no_of_messages} = $imap_status->{MESSAGES};
  $status->{no_of_unseen}   = $imap_status->{UNSEEN};

  # fetch all message ids (as array reference)
  my $messages = $self->imap->search('ALL NOT DELETED', 'DATE');

  return {
    folder         => $folder,
    folder_status  => $status,
    messages       => []
    }
    unless ($status->{no_of_messages});

  my $stop = 30;
  $stop = $status->{no_of_messages} if ($status->{no_of_messages} < $stop);

  my @range = @{$messages}[0 .. $stop];

  my $headers = 'BODY[HEADER.FIELDS (SUBJECT FROM DATE)]';

  my $results = $self->imap->fetch(\@range, "FLAGS $headers");

  my ($m, $flags, $subject, $from, $body, $date, @mail_headers);

  foreach my $hash (@$results) {
    $flags = join(" " . @{$hash->{FLAGS}}) . "\n";

    my $uid = $hash->{UID};

    my @mail_headers = split(/\n/, $hash->{$headers});

    foreach (@mail_headers) {
      chop($_);

      $subject = $1 if (s/^Subject:\s+(.*)//);
      $from    = $1 if (s/^From:\s+(.*)//);
      $date    = $1 if (s/^Date:\s+(.*)//);
    }

    $from =~ m/([^<(]+) [<(]([^@]+@[^>]+)[)>]/;

    my $name = $1;
    my $addr = $2;

    push(
      @$m,
      {
        uid     => $uid,
        flags   => $flags,
        from    => {addr => $addr, name => $name, full => $from},
        subject => $subject,
        date    => $date,
        body    => $body
      }
    );
  }

  return {
    folder         => $folder,
    folder_status  => $status,
    messages       => $m
  };
}

sub message {
  my ($self, $folder, $message_id) = @_;
  croak('folder missing')     unless defined($folder);
  croak('message_id missing') unless defined($message_id);

  $self->imap->select($folder);

  my $message = $self->imap->fetch($message_id,
    'UID FLAGS RFC822.SIZE BODY.PEEK[HEADER] BODY.PEEK[TEXT]');

  croak('No such e-mail') unless (defined($message));

  return $message;
}

1;

