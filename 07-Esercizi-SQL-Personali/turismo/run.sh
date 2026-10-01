#!/usr/bin/env bash
# Usage:
#   ./run.sh              runs query.sql
#   ./run.sh file.sql     runs another file
#   ./run.sh psql         opens an interactive psql shell
#   ./run.sh reset        recreates the database from scratch (schema + data)
#   ./run.sh stop         stops and removes the container
# Real-time: watch -n 1 ./run.sh   (re-runs query.sql every second, so each save shows up)
DB=turismo
PORT=5434
source "$(dirname "$0")/../common.sh"
