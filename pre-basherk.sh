#!/bin/bash
# pre-basherk
# © Trav Easton 2016

# fix for mail before anything else
[[ $HOSTNAME != *"mail"* ]] && shopt -s nocasematch
