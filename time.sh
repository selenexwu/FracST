#!/usr/bin/env bash

syntax=("implicit" "explicit")
tests=("nat" "bin" "queue" "stack" "tree" "avl_tree" "mapreduce" "ring_leader" "auction")

mkdir -p times

# remove variance due to gc timing
export OCAMLRUNPARAM="s=1000000000,o=1000000"
for s in "${syntax[@]}"; do
    mkdir -p times/$s
    for t in "${tests[@]}"; do
        echo "$t - $s"
        rm -f times/$s/$t.times
        for i in {1..10}; do
            ./_build/default/bin/fracst.exe -v 2 -s $s tests/$s/$t.frac >> times/$s/$t.times
        done
        awk '{sum+=$1; count++} END {if (count > 0) print sum/count}' times/$s/$t.times
    done
done
