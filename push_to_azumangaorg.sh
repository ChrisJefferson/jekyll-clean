#/usr/bin/env bash
set -ex

bundle exec jekyll build
rsync -avr --delete-after --delete-excluded _site/ caj_azumangaorg@ssh.phx.nearlyfreespeech.net:
