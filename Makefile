# Copyright © 2014 Kosma Moczek <kosma@cloudyourcar.com>
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See the COPYING file for more details.

CFLAGS = -g -Wall -Wextra -Werror -std=c99
CFLAGS += -D_POSIX_C_SOURCE=199309L -D_BSD_SOURCE -D_DEFAULT_SOURCE -D_DARWIN_C_SOURCE
CFLAGS += $(shell pkg-config --cflags check)
LDLIBS += $(shell pkg-config --libs check)

SRC_DIR = minmea

all: scan-build test example
	@echo "+++ All good."""

test: $(SRC_DIR)/tests
	@echo "+++ Running Check test suite..."
	./$(SRC_DIR)/tests

example: $(SRC_DIR)/example

scan-build: clean
	@echo "+++ Running Clang Static Analyzer..."
	scan-build $(MAKE) $(SRC_DIR)/tests

clean:
	$(RM) $(SRC_DIR)/tests $(SRC_DIR)/example $(SRC_DIR)/*.o

$(SRC_DIR)/tests: $(SRC_DIR)/tests.o $(SRC_DIR)/minmea.o
$(SRC_DIR)/example: $(SRC_DIR)/example.o $(SRC_DIR)/minmea.o
$(SRC_DIR)/tests.o: $(SRC_DIR)/tests.c $(SRC_DIR)/minmea.h
$(SRC_DIR)/minmea.o: $(SRC_DIR)/minmea.c $(SRC_DIR)/minmea.h

.PHONY: all test scan-build clean
