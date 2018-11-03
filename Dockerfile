FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y \
  build-essential \
  check \
  clang-6.0 \
  gcc \
  git \
  lcov \
  pkg-config \
  python \
  python-pip

RUN pip install cpp-coveralls

COPY . /tmp/minmea

CMD bash -c \
  "cd /tmp/minmea && \
  make test -j6 && \
  if [ -f coverage_filtered.info ]; \
  then coveralls -n -i ./ -e example.c -l coverage_filtered.info; \
  fi"
