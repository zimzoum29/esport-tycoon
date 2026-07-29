# Esport Tycoon — LÖVE2D

Même bac à sable visuel que ce qu'on venait de faire en Phaser, porté en
Lua/LÖVE2D — sol, murs, mobilier, avatar en click-to-move. Aucune logique de
manager pour l'instant, volontairement : l'idée est de peaufiner le style
avant de brancher `GameState`/les actions par pièce.

## Lancer le projet
Installe LÖVE (https://love2d.org, `brew install love` sur Mac, `love2d`
via ton gestionnaire de paquets sur Linux), puis :
```
love .
```
depuis ce dossier.

Je n'ai pas de vrai environnement LÖVE ici pour vérifier le rendu à l'écran
(pas d'affichage graphique dans ce sandbox), mais j'ai fait tourner
`main.lua` avec un `love.graphics` factice pour vérifier qu'il n'y a aucune
erreur d'exécution — 105 appels de dessin, exactement le compte attendu
(96 tuiles de sol/mur + porte + mobilier + avatar). Dis-moi ce que ça donne
une fois lancé.

## Structure
```
conf.lua     titre et taille de fenêtre, lu avant love.load()
main.lua     tout le bac à sable : love.load / love.update / love.draw
assets/      les mêmes 10 PNG que la version Phaser (sol, murs, mobilier, avatar)
```

## Comment c'est organisé
`tilePos(col, row)` convertit une position de grille en pixels — la même
formule que côté Phaser, donc si tu veux comparer les deux versions plus
tard, l'agencement de la pièce restera identique. `drawCentered()` recentre
chaque sprite sur son point d'ancrage, pour que la position corresponde au
centre de l'image plutôt qu'à son coin (LÖVE dessine par défaut depuis le
coin haut-gauche).

## Pour itérer sur le style
Remplace les PNG de `assets/` par tes propres dessins, même noms de
fichiers — tout continue de s'aligner. Pour réorganiser la pièce, les
positions du mobilier sont en dur dans `love.draw()` (les `tilePos(col, row)`
qu'on appelle pour chaque objet) — change les chiffres.

## Prochaine étape
Une fois le style validé, on porte `GameState`/`ROOM_ACTIONS` (déjà écrits
en TypeScript, la traduction en Lua est directe) et on rend les pièces
cliquables — exactement ce qu'on avait dans `LocaleScene.ts`, en Lua cette
fois.
