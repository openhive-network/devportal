#!/bin/bash

for d in `ls -d */`; do
  echo "*** $d ***"
  cd $d
  yarn install && rm yarn.lock || exit
  cd ..
done
