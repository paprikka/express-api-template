#!/bin/sh

# exec jest po to żeby w drzewie procesow
# nie bylo daemon->sh->node tylko daemon->node
# inaczej daemon nie potrafi poprawnie zabic node'a

# readlink -f zwraca pelna sciezke do pliku
# potrzebne do identyfikacji procesu przez nagiosa

exec node $(readlink -f server.js)