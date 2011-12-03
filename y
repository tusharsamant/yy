#!/bin/sh -e

ROOT=$HOME/.yy

export Y
Y=`basename $0`

export YHERE
if [ x$YHERE = x ]; then
    YHERE=`pwd`
fi

export YTHIS
if [ x$YTHIS = x ]; then
    YTHIS=yy
fi

ctx=$ROOT/$YTHIS
cd $ctx

if [ x$1 = x ]
    then
    echo Usage: $Y command arguments; echo Commands:
    find bin -type f -a -perm -0555 | sort | sed 's!bin/!!' | while read c
    do
    /bin/echo -n '    '$c
    if [ -r doc/$c.short ]; then
        /bin/echo -n ' - '
        cat doc/$c.short
    else
        echo
    fi
    done
    exit
fi

cmd=$1
shift
# startup if necessary

while [ ! -e ./bin/$cmd -a -s super ]; do
    cd super
done
if [ ! -e ./bin/$cmd ]; then
    cd $ROOT/yy
fi
cmd=`pwd`/bin/$cmd

if [ ! -e $cmd ]; then
    echo Command not found. 1>&2
    exit 1
fi

cd $ctx
$cmd "$@"
