# st - simple terminal
# See LICENSE file for copyright and license details.

VERSION = 0.6

# paths
PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# includes and libs
INCS = -I. -I/usr/include -I${X11INC} \
       `pkg-config --cflags fontconfig` \
       `pkg-config --cflags freetype2`
LIBS = -L/usr/lib -lc -L${X11LIB} -lm -lrt -lX11 -lutil -lXft \
       `pkg-config --libs fontconfig`  \
       `pkg-config --libs freetype2`

# flags
CPPFLAGS = -DVERSION=\"${VERSION}\" -D_XOPEN_SOURCE=600
CFLAGS += -g -std=c99 -pedantic -Wall -Wvariadic-macros -Os ${INCS} ${CPPFLAGS}
LDFLAGS += -g ${LIBS}

# compiler and linker
# CC = cc

SRC = src/st.c
OBJ = ${SRC:.c=.o}

all: options st stc std

options:
	@echo st build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	@echo CC $<
	@${CC} -o $@ -c ${CFLAGS} $<

${OBJ}: src/config.h

st: ${OBJ}
	@echo CC -o $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

src/stc.o:
	@echo CC src/stc.c
	@${CC} -o src/stc.o -c ${CFLAGS} src/stc.c

stc: src/stc.o
	@echo CC -o $@
	@${CC} -o stc src/stc.o ${LDFLAGS}

src/std.o:
	@echo CC src/std.c
	@${CC} -o src/std.o -c ${CFLAGS} src/std.c

std: src/std.o
	@echo CC -o $@
	@${CC} -o std src/std.o ${LDFLAGS}

clean:
	@echo cleaning
	@rm -f st stc std src/stc.o src/std.o ${OBJ} st-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p st-${VERSION}
	@cp -R LICENSE Makefile README doc/st.info doc/st.1 src/arg.h ${SRC} st-${VERSION}
	@tar -cf st-${VERSION}.tar st-${VERSION}
	@gzip st-${VERSION}.tar
	@rm -rf st-${VERSION}

install: all
	@echo installing executable file to ${DESTDIR}${PREFIX}/bin
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f st ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/st
	@echo installing manual page to ${DESTDIR}${MANPREFIX}/man1
	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
	@sed "s/VERSION/${VERSION}/g" < doc/st.1 > ${DESTDIR}${MANPREFIX}/man1/st.1
	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/st.1
	@echo Please see the README file regarding the terminfo entry of st.
	@tic -s doc/st.info

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/st
	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/st.1

.PHONY: all options clean dist install uninstall
