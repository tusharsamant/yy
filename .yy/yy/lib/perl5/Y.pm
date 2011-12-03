package Y;

use autodie;
use strict;
use warnings;

use Cwd;

sub path {
    my $name = shift;
    while (!-e "files/$name" and -s "super") {
        chdir 'super';
    }
    getcwd() . "/files/$name";
}

sub get {
    my $name = shift;
    open(my $fh, path($name));
    join '', <$fh>
}

sub setting {
    get("settings/$_[0]");
}

1;
