#!/bin/bash
# Warhammer 40K Inquisition quotes about Perl, in sPoNgEbOb CaSe
curl -sN https://wh40k.lexicanum.com/wiki/Inquisition_Quotes | perl -lane 'print "$1$2$3\n\n" if /<b>(.*?)(orderless)(.*?)<\/b>/' | perl -ne 's/<a.*?>(.*?)<\/a>/$1/g;s/[tT]he [wW]arp|[cC]haos/Perl/g;s/[iI]nquisitor/programmer/g;s/An p/A p/g;foreach $char (split //, $_) {print $s++%2 ? uc $char : lc $char}' | perl -pe 's/(step|warp|help|perl)g/$1/ig' | lolcat
