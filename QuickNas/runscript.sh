#!/bin/sh
command=$1
password=$2
echo $password | sudo -S $command