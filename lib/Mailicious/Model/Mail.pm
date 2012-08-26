package Mailicious::Model::Mail;
use Mojo::Base 'Mojolicious::Controller';
use Email::MIME::Encodings;
use Net::IMAP::Client;

has imap => sub {
  my $self = shift;

  # TODO: This should be fetched from something like Mojolicious::Plugin::Config
  my $imap = Net::IMAP::Client->new(
    server => '',
    user   => '',
    pass   => '',
    ssl    => 1,
    port   => 993
  ) or die "Could not connect to IMAP server";

  return $imap;
};

sub get_folders {
  my $self = shift;

  return $self->imap->folders;
}

sub get {
  my $self = shift;
  my $folder = shift || 'INBOX';

  $self->imap->login or die('Login failed: ' . $self->imap->last_error);

  $self->imap->select($folder);

  # fetch all message ids (as array reference)
  my $messages = $self->imap->search('ALL', 'DATE');

  my $no_of_messages = scalar(@{$messages});

  return {folder => $folder, messages => [], no_of_messages => $no_of_messages}
    unless ($no_of_messages);

  # NOTE: This is unpretty
  my $start = ($no_of_messages-30);
  $start = 1 if ($start < 1);

  my @range = ($start .. $no_of_messages);

  my $headers = 'BODY[HEADER.FIELDS (Subject From)]';

  my $results = $self->imap->fetch(\@range, "FLAGS $headers");

  my ($m, $flags, $subject, $from, $body, @mail_headers);

  foreach my $hash (@$results) {
    $flags = join(" " . @{$hash->{FLAGS}}) . "\n";

    my $uid = $hash->{UID};

    my @mail_headers
      = split(/\n/, $hash->{'BODY[HEADER.FIELDS (SUBJECT FROM)]'});

    foreach (@mail_headers) {
        chop($_);

        $subject = $1 if (s/^Subject: (.*)//);
        $from    = $1 if (s/^From: (.*)//);
    }

    $from =~ m/([^<(]+) [<(]([^@]+@[^>]+)[)>]/;

    my $name = $1;
    my $addr = $2;

    push(
      @$m,
      {
        uid     => $uid,
        flags   => $flags,
        from    => {
          addr  => $addr,
          name  => $name,
          full  => $from,
        },
        subject => $subject,
        body    => $body,
      }
    );
  }

  return {folder => $folder, messages => $m, no_of_messages => $no_of_messages};
}

1;
