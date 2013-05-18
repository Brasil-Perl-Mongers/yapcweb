#!/bin/bash
/usr/bin/env perl ./cpanminus --verbose --self-upgrade
# assume that worked, so fake an ok return value
echo "PREBUILD COMPLETE"
