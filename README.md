# yy - painless command line apps

## INTRODUCTION

For a heavy philosophical preface, go to the end of this file.

`yy` is a few lines of shell and a few conventions.

`yy` makes it easy to run and program self-contained command line
applications. It favors the view that an application is a set of cooperating
single-purpose programs. Thus, in its own way, it adheres to the Unix&trade;
philosophy.

`yy` comes with a few basic building blocks and a few apps built with them,
to get you started with tinkering. The apps, unmodified, are usable as well;
the author uses them extensively.

`yy` apps are friendly to the modern shell user. They lean away from cryptic
command line options and make extensive use of command line completion
(*note:* currently only for `zsh`).

## INSTALLATION

`yy` is mildly zsh-centric at the moment, and so are these instructions.
Hopefully they are easy to carry over to other shells. Certain parts are
Perl-centric in addition, and certain others are heavily SQLite-dependent.
These should not be big problems. To install:

1. Copy the script y to some place in your $PATH.
2. Copy .yy to your home directory.
3. Install the function yy in yy.zsh somewhere in your zsh startup; mutatis
mutandis if you use another shell.
4. Restart your shell, e.g. with `exec $SHELL`.

You are now ready to get productive with `yy`. Let us start with a simple
but very useful example.

## THE `rsync` APP

`yy`'s usage resembles contemporary command line interfaces such as `git`'s,
but there is one significant difference. The `yy` app named `rsync` will
make this clear.

To use it, you must first signal your intention with `yy`:

    % yy rsync

You have now switched to the `rsync` application. 

*Note:* The internals of this, to be touched on later, are disappointingly
low-tech.

The command `y` will now drive the various functions--or subcommands, or
methods--that the `rsync` app provides.

    % y get remote
    cloudhost1:

The `get` command prints a resource. `rsync` happens to have a resource named
`remote`. `get` is in fact predefined for all `yy` apps, along with a few other
commands that will come up soon.

`y` is now set to drive the `rsync` app, and the `rsync` app is set to rsync
to and from `cloudhost1`. Perhaps that is not the host you want. You can set
the remote location to something else:

    % echo 'cloudhost2:' | y put remote
    remote exists; to change it, follow with 'really'

`y put` is finicky.

    % echo 'cloudhost2:' | y put remote really

Success:

    % y get remote
    cloudhost2:

This was a convenient example to illustrate `get` and `put`; actually
`rsync` has a function called `remote` as well, and it does all of these
things with a few sanity checks:

    % y remote
    cloudhost2:

    % y remote cloudhost1:
    % y remote
    cloudhost1:

    % y remote ~/Dropbox
    remote location must end in : or /
    % y remote ~/Dropbox/

Time for the juicy stuff--the `rsync` app is, as was probably obvious, a
wrapper on the real rsync. What it does is rsync between your current
directory and a directory of the same name at the remote location.

    % mkdir -p /tmp/yytest ~/Dropbox/tmp/yytest
    % cd /tmp/yytest
    % y out
    incremental file list

    sent 35 bytes  received 12 bytes  94.00 bytes/sec
    total size is 0  speedup is 0.00 (DRY RUN)

It ran rsync all right. Because of the default invocation, it did a dry run.

    % echo TEST > file_one
    % y out
    sending incremental file list
    ./
    file_one

    sent 58 bytes  received 18 bytes  152.00 bytes/sec
    total size is 5  speedup is 0.07 (DRY RUN)

As is probably obvious:

    % y out really
    incremental file list
    ./
    file_one

    sent 103 bytes  received 34 bytes  274.00 bytes/sec
    total size is 5  speedup is 0.04

Now that they are identical:

    % y out
    sending incremental file list

    sent 52 bytes  received 12 bytes  128.00 bytes/sec
    total size is 5  speedup is 0.08 (DRY RUN)

The general flow with this app is as follows: set the "remote" location with
`y remote`, after which `y in` and `y out` synchronize to and from the
current directory respectively. There are a few modes:

`y out light` refrains from clobbering the destination files, i.e. it does
`--ignore-existing`.

`y out heavy` not only clobbers files, but also does the equivalent of
`--delete`.

`y out existing` does the equivalent of `--existing`.

The default is: synchronize all files, clobbering if necessary, but don't
delete files that are absent at source.

`y in` has the same modes.

Appending `really` actually runs the rsync. The default is a dry run.

`y options` simply shows the options passed to rsync in various modes.

    % y options out heavy
    --verbose --archive --dry-run --delete

It was probably obvious that *most of this is tab-completable in zsh*. The
driving force behind `yy` is to make common tasks easy to remember and very
fast to type, without cluttering the global space of aliases, functions,
commands and completion directives.

There are a few more twists to `y rsync`. They are intended to make life
easier but may make for surprises if not understood. See the app's man page
for details.

## THE `news` APP

Perhaps it is time to switch to the `news` app, which is a decentralized RSS
newsreader.

    % yy news
    % yy
    news

Aside: you could put your current `yy` app in a prompt:

    % setopt prompt_subst
    % RPS1='[$YTHIS]'

Anyhow,

    % y sqlite3
    SQLite version 3.7.6
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> ^D
    %

The `news` app uses SQLite heavily. In fact, the `sqlite3` command is
predefined for all `yy` apps, along with `dbquery`, `dbread`, `dbrun`,
`dbrunfile`, and `dbwrite`. Perl and `DBD::SQLite` are required for these.
Needless to say, all of these could be reimplemented in another language of
your choice--`yy` does not care.

As an end user you will rarely need to run `y sqlite3`. As a programmer, you
could use this simple facility to maintain all sorts of state in a database
dedicated to the app. For instance, this is one way to initialize the `news`
app:

    % y get schema.sql | y sqlite3

You probably don't need it; the database comes initialized with the schema.
You need it even less after having used the app a bit; it will try to reset
your whole newsreading history (luckily, in this case it will fail).

Moving on:

    % y import some-opml.xml
    % y feeds-like google
    http://googlebase.blogspot.com/feeds/posts/default
    http://googlecheckout.blogspot.com/atom.xml
    http://feeds.feedburner.com/OfficialGoogleMacBlog
    http://googlemapsapi.blogspot.com/feeds/posts/default
    http://feedproxy.google.com/blogspot/RBev
    http://googlecustomsearch.blogspot.com/atom.xml
    http://googlegeodevelopers.blogspot.com/feeds/posts/default?alt=rss

Pretty boring. A word of explanation about `feeds-like`: it just searches
for the given string in the url of the feed.

The daily flow goes like this:

    % y fetch-feeds verbose 10

Fetches 10 feeds ripe for fetching. (You will probably tire of `verbose` after
a short while.)

    % y process-feeds verbose 5

Extracts stories from 5 feeds ripe for processing and delivers them to the
app's dedicated maildir.

    % y read

Starts mutt on the maildir. Yes, this one is a bit mutt-centric, but
hopefully it's not very difficult to change that:

    % cat ~/.yy/news/bin/read
    if [ "x$1" = "xmenu" ]
    then
        cd stories
        echo *
        exit
    fi

    if [ "x$1" = "x" ]
    then
        mutt -F `$Y path muttrc`
    else
        mutt -F `$Y path muttrc` -f stories/$1
    fi

Essentially it starts mutt with an app-specific muttrc. One of the features
of this muttrc is that `v` will open the full story in a web browser.

Aside: the `menu` part in the above script is how tab completion is done:

    % y read mu<TAB>

will complete to:

    % y read music

If you have a maildir named `music`, of course. And you need some feeds
assigned to the `music` folder, so that `process-feeds` delivers stories to
that maildir.

For programmers, the `yy` convention here is: if `y cmd menu` prints a list
of words, `y cmd` will tab-complete to that list. This is already implemented
for `zsh`.

There are a few more `yy news` commands--to subscribe to a feed, analyze and
adjust polling periods, find dead or very quiet feeds, etc. These are
described in the manual.

As is probably obvious, `yy news` was written out of frustration with feed
readers that you cannot control well, and which land you into a user
interface you don't care about. This one lets you poll feeds when you want
it to, keeps network fetches to a minimum, does offline everything that
doesn't need a connection, and lets you read news with your favorite mail
client.

Backing up the state of your newsreading is easy: get out of the app, and
copy or rsync `~/.yy/news/` someplace. You could use `yy rsync` to do that
...

## THE `rage` APP

This exists solely so you can run `y u no`. Ignore it.

## THE `calendar` APP

To be written.

# THE `weather` APP

Good example of how a `yy` app can be written in "half an evening". This one
just stores the wunderground API key, makes only one type of call and prints
a reasonably formatted answer.

## PROGRAMMING

The stucture of the code is roughly object-oriented: `yy` can be thought of
as picking a "class", from which "methods" are dispatched by `y`. An app
named `example` resides in the directory `~/.yy/example`. There are a few
conventions for files in this directory: the "on-board" SQLite database, if
any, is called `db`. "Resources" are files in `files/`. Certain resources
are SQLite queries, and they are kept in `files/queries`.
`files/schema.sql`, though strictly not necessary, is often kept as the db
schema for the app. There is a `tmp` directory free for you to use. The
`bin` directory holds all commands; the `doc` directory, all manuals.

Finally, each app "inherits" from the app called `yy`, which is of course in
`~/.yy/yy`. It's a simple way to share common subcommands.

*The most important point is:* the working directory of the app is the root
of the app. After `yy example` is run, `y cmd` basically amounts to `(cd
~/.yy/example; ./bin/cmd)`.

## HEAVY PHILOSOPHICAL PREFACE

The command/subcommand pattern makes for highly effective interaction with
command line applications. The commands `git commit`, `git add` et al make
for a better user interface than scores of commands resembling `ppmtopng`,
`giftoppm` etc.

But an app needs more than a neat organization into subcommands. It may need
state, user profiles, other resources. Stashing all of this in a `dotfile`
is one reflexive habit. Unfortunately, that leads to clutter; the tidiness
achieved by subcommands is lost.

Another old habit--short, cryptic options--clutters in a different way. It
mars the verbal expressivity of the command line. Programs with dozens of
options are, it could be argued, repugnant to Unix itself.

What if the command/subcommand metaphor were further extended--so much
further that it began to resemble a class/method pattern? What if it were
acknowledged that a "wordy" command line is not a hindrance but a help, if a
shell can autocomplete most of it?

`yy` is the result of thinking on these lines. `yy` reduces clutter, in your
filesystem and your head, and makes running applications a pleasure. It also
makes writing new applications or modifying old ones a breeze, because it
blurs the distinction between using and programming.

`yy` gets things done, from the best user interface of all: the command line.

