#!/usr/bin/env bash
# Test driver for image file i/o

source ./functions.source

(   cd "$testdir"

    errors=0
    test_files="table.jpg smiley2.jpg ext.dat"
    echo
    printf "file io tests"
    for i in $test_files; do ioTest $i; done

    printf "\n---------------------------------------------------------\n"
    if [ $errors -eq 0 ]; then
       echo 'All test cases passed'
    else
       echo $errors 'test case(s) failed!'
    fi
)

# Test http I/O
if [ "$EXIV2_PORT" != "None" -a "$EXIV2_HTTP" != "None" ]; then
    startHttpServer
    if [ ! -z $exiv2_httpServer ]; then
        (   cd "${testdir}" 
            >&2 printf "*** HTTP tests begin\n"

            cd "$testdir"
            test_files="table.jpg Reagan.tiff exiv2-bug922a.jpg"
            for i in $test_files; do
                runTest iotest s0 s1 s2                    $url/data/$i
                for t in s0 s1 s2 $url/data/$i; do
                    runTest exiv2 -g City -g DateTime $t
                done
            done
            runTest iotest s0 s1 s2 $url/data/table.jpg 1
            echo $(stat -c%s s0 s1 s2 ../data/table.jpg)
            runTest iotest s0 s1 s2 $url/data/table.jpg 10
            echo $(stat -c%s s0 s1 s2 ../data/table.jpg)
            runTest iotest s0 s1 s2 $url/data/table.jpg 1000
            echo $(stat -c%s s0 s1 s2 ../data/table.jpg)
            >&2 printf "*** HTTP tests end\n"
        )  | tr -d '\r' | sed 's/[ \t]+$//' > $results
        reportTest
    fi
    closeHttpServer
fi

# That's all Folks!
##