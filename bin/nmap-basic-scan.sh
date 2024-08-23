#!/bin/bash

nmap -iL ips.txt -Pn -sV --version-light -O --osscan-limit

