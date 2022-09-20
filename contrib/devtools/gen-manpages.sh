#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

RAVEND=${RAVEND:-$SRCDIR/redecoind}
RAVENCLI=${RAVENCLI:-$SRCDIR/redecoin-cli}
RAVENTX=${RAVENTX:-$SRCDIR/redecoin-tx}
RAVENQT=${RAVENQT:-$SRCDIR/qt/redecoin-qt}

[ ! -x $RAVEND ] && echo "$RAVEND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
REDEVER=($($RAVENCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for redecoind if --version-string is not set,
# but has different outcomes for redecoin-qt and redecoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$RAVEND --version | sed -n '1!p' >> footer.h2m

for cmd in $RAVEND $RAVENCLI $RAVENTX $RAVENQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${REDEVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${REDEVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
