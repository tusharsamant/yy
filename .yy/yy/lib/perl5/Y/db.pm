package Y::db;

use autodie;
use strict;
use DBI;

our $TXN_SIZE = 200;
our $DB_NAME = 'db';

my($dbh, %st, $modifications);

sub _connect {
    $dbh = DBI->connect(
        "dbi:SQLite:dbname=$DB_NAME","","",
        { PrintError => 0, RaiseError => 1 }
    );

    $dbh->sqlite_update_hook(sub {
        my($act, $db, $table, $rowid) = @_;
        return unless $db eq 'main';
        $modifications++;
    });
    $dbh->begin_work;
}

sub register {
    my($name, $sql) = @_;
    if (exists $st{$name}) {
        die "Query $name exists";
    }
    if (!defined $sql) {
        open(my $f, "files/queries/$name");
        $sql = join '', <$f>;
        close $f;
    }
    _connect() unless $dbh;
    $st{$name} = $dbh->prepare($sql);
}

sub run {
    my($name, @args) = @_;
    unless (exists $st{$name}) {
        die "Query $name does not exist";
    }
    eval {
        $st{$name}->execute(@args);
        if ($modifications >= $TXN_SIZE) {
              $dbh->commit;
              $dbh->begin_work;
              $modifications = 0;
        }
    }; if ($@) {
        $dbh->rollback();
        die $@;
    };
    $st{$name};
}

sub END {
    if ($dbh) {
        $dbh->commit;
        $dbh->disconnect;
    }
}

1;
