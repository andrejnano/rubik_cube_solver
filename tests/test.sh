#!/bin/bash

for run in {1..10}
do
  echo "Running test #${run} =>"
  ./flp20-log < tests/${run}-move.in
done
