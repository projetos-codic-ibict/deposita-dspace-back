#!/usr/bin/bash

ls -1 *.sql | while read arquivo; do
  docker cp "$arquivo" dspacedb:/tmp
done
