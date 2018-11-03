# Copyright © 2014 Kosma Moczek <kosma@cloudyourcar.com>
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See the COPYING file for more details.

CFLAGS = -g -Wall -Wextra -Werror -std=c99
CFLAGS += -D_POSIX_C_SOURCE=199309L -D_BSD_SOURCE -D_DEFAULT_SOURCE -D_DARWIN_C_SOURCE

ifeq ($(MINMEA_COVERAGE),1)
CFLAGS += --coverage

# Set LCOV if available
LCOV ?=
endif

# Optionally use AddressSanitizer and UndefinedBehaviorSanitizer
ifeq ($(MINMEA_ASAN),1)
CFLAGS += -fsanitize=address -fsanitize=undefined
endif

CFLAGS += $(shell pkg-config --cflags check)
LDLIBS += $(shell pkg-config --libs check)

all: scan-build test example
	@echo "+++ All good."""

test: tests
	@echo "+++ Running Check test suite..."
	./tests
	@# Run coverage if enabled
ifeq ($(MINMEA_COVERAGE),1)
ifdef LCOV
	@echo "+++ Running lcov..."
	$(LCOV) --quiet --rc lcov_branch_coverage=1 --capture --directory ./ --output-file coverage.info
	$(LCOV) --quiet --rc lcov_branch_coverage=1 --remove coverage.info "*test*" -o coverage_filtered.info
	genhtml --branch-coverage coverage_filtered.info --output-directory coverage
	@echo "See file://$(abspath coverage)/index.html for lcov results"
endif
endif

scan-build: clean
	@echo "+++ Running Clang Static Analyzer..."
	scan-build $(MAKE) tests

clean:
	$(RM) tests example *.o

tests: tests.o minmea.o
	$(CC) $(CFLAGS) $^ $(LDLIBS) -o $@

example: example.o minmea.o
	$(CC) $(CFLAGS) $^ $(LDLIBS) -o $@

tests.o: tests.c minmea.h
minmea.o: minmea.c minmea.h

.PHONY: all test scan-build clean
