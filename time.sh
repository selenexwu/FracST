#!/usr/bin/env bash

tests=("stack" "queue" "tree" "nat" "bin" "ring_leader" "mapreduce" "auction" "avl_tree")

mkdir -p times/implicit
mkdir -p times/explicit

run_test() {
    local t="$1"
    local s="$2"
    rm -f times/$s/$t.times
    for i in {1..10}; do
        ./_build/default/bin/fracst.exe -v 2 -s $s tests/$s/$t.frac | sed -n -E 's/typechecking( \+ reconstruction)? time: ([0-9]+\.[0-9]+)s/\2/p' >> times/$s/$t.times
    done
    avg=$(awk '{sum+=$1; count++} END {if (count > 0) print sum/count}' times/$s/$t.times)
}

command -v cloc &>/dev/null || echo "WARNING: cloc not found, line counts will not be printed"

# remove variance due to gc timing
export OCAMLRUNPARAM="s=1000000000,o=1000000"
for t in "${tests[@]}"; do
    echo "Running test '$t'"
    run_test "$t" implicit
    tcr_avg="$avg"
    run_test "$t" explicit
    tc_avg="$avg"
    r_avg=$(awk -v n1=$tcr_avg -v n2=$tc_avg 'BEGIN {print n1 - n2}')
    echo "Average typechecking time: $tc_avg"
    echo "Average reconstruction time: $r_avg"
    if command -v cloc &> /dev/null; then
        i_lines=$(cloc --force-lang OCaml tests/implicit/$t.frac --quiet --csv | tail -n 1 | cut -d, -f5)
        e_lines=$(cloc --force-lang OCaml tests/explicit/$t.frac --quiet --csv | tail -n 1 | cut -d, -f5)
        echo "Implicit lines: $i_lines"
        echo "Explicit lines: $e_lines"
    fi
    echo
done
