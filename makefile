
# make install -> install bash.utils in ~/lib

src := $(wildcard *.sh)

install: $(src)
	mkdir -p $(HOME)/lib/bash.utils
	install --compare -D *.sh $(HOME)/lib/bash.utils

