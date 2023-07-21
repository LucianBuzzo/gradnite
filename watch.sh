#! /bin/bash

watchexec -w src -r "crystal src/main.cr && dot -Tpng tree.dot -o tree.png"