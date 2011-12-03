yy () {
    if [ x$1 = x ]
    then
        echo $YTHIS
        return
    fi
    _ythat=$1 
    shift
    if [ x$1 = x ]
    then
        YTHIS=$_ythat 
        . <(y zshsetup)
    else
        (
            YTHIS=$_ythat 
            y "$@"
        )
    fi
}
