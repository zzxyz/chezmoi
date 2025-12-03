#!/bin/bash
# The Psalm of Perl - Psalm 23 with appropriate substitutions
(echo "A Psalm of David" && curl -s "https://bible-api.com/psalms+23?translation=kjv" | perl -0777 -ne '/\],"text":"(.*?)","translation_id"/s && print $1' | perl -pe 's/\\n/\n/g') | perl -lpe 's/([Tt]he LORD|LORD\b)/PERL/g;s/\b(the lord|lord\b|thou\b|he\b)/Perl/gi;s/thy/Perl'"'"'s/gi;s/David/Tyler/;s/rod/regexes/;s/staff/one-liners/;s/his/its/gi'
