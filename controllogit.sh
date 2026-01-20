#!/bin/bash

echo "Controllo stato git..."
git status

echo "Aggiungo tutte le modifiche (incluso submodule)..."
git add -A

echo "Fai un commit con messaggio descrittivo:"
read -p "Inserisci messaggio commit: " commit_msg

if [ -z "$commit_msg" ]; then
  echo "Messaggio commit vuoto, esco."
  exit 1
fi

git commit -m "$commit_msg"

echo "Push sul branch corrente..."
git push origin HEAD

echo "Fatto! GUI e submodule dinastycoin aggiornati su GitHub."
