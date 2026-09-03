#!/bin/bash
# Alpha Signal Generator — hourly cron job
# Add to crontab: 0 * * * * /home/fabio/projects/agent-wealth/alpha-generator/run-hourly.sh

cd /home/fabio/projects/agent-wealth/alpha-generator
/usr/bin/python3 alpha_signals.py >> cron.log 2>&1
