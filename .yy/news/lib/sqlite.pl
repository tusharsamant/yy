#!/usr/bin/env perl

use warnings;
use strict;
use integer;
use DBI;
use HTTP::Date;

my $TXN_SIZE = 200;
my $modifications = 0;

my $dbh = DBI->connect(
  "dbi:SQLite:dbname=db","","",
  { PrintError => 0, RaiseError => 1 }
);

$dbh->begin_work;

END {
  $dbh->commit;
  $dbh->disconnect;
};

$dbh->sqlite_update_hook(sub {
  my($act, $db, $table, $rowid) = @_;
  return unless $db eq 'main';
  $modifications++;
});

my %st = (
  item_seen => 'select date from item where url = ?',
  see_item => 'insert into item(url, date, folder, filename, recipient,
    subject) values (?, ?, ?, ?, ?, ?)',
  subscribe => 'insert into feed(url, name, folder) values (?, ?, ?)',
  feeds => 'select url, name, folder, seen, frequency from feed',
  see_feed => 'update feed set seen = ? where url = ?'
);

$st{$_} = $dbh->prepare($st{$_}) for keys %st;

my $perform = sub {
  my($act, @args) = @_;
  eval {
    $st{$act}->execute(@args);
    if ($modifications >= $TXN_SIZE) {
      $dbh->commit;
      $dbh->begin_work;
      $modifications = 0;
    }
  }; if ($@) {
    $dbh->commit();
    die $@;
  };
  $st{$act};
};

sub subscribe { $perform->(subscribe => @_) }

sub eligible_feeds {
  my @result;
  my $feed_h = $perform->('feeds');
  my $now = time;
  while (my($url, $name, $folder, $seen, $frequency) = $feed_h->fetchrow_array) {
    if (!defined($seen) or (str2time($seen) + $frequency < $now)) {
      push @result, [$url, $name, $folder, $seen];
    }
  }
  @result;
}

sub see_feed {
  my($url, $t) = @_;
  $perform->(see_feed => time2str($t), $url);
}

sub see_item {
  my($story, $folder) = @_;
  $perform->(
    see_item => $story->{'X-Url'}, $story->{Date}, $folder, 'FILENAME',
    $story->{To}, $story->{Subject}
  );
}

sub item_seen {
  my($url) = @_;
  if (my($date) = $perform->(item_seen => $url)->fetchrow_array) {
    return($date);
  }
  else {
    return
  }
}

1;
