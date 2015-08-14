BEGIN { $| = 1; print "1..31\n"; }

use utf8;
use JSON::XS::Stable;
no warnings;

our $test;
sub ok($) {
   print $_[0] ? "" : "not ", "ok ", ++$test, "\n";
}

eval { JSON::XS::Stable->new->encode ([\-1]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::XS::Stable->new->encode ([\undef]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::XS::Stable->new->encode ([\2]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::XS::Stable->new->encode ([\{}]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::XS::Stable->new->encode ([\[]]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::XS::Stable->new->encode ([\\1]) }; ok $@ =~ /cannot encode reference/;

eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('"\u1234\udc00"') }; ok $@ =~ /missing high /;
eval { JSON::XS::Stable->new->allow_nonref->decode ('"\ud800"') }; ok $@ =~ /missing low /;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('"\ud800\u1234"') }; ok $@ =~ /surrogate pair /;

eval { JSON::XS::Stable->new->decode ('null') }; ok $@ =~ /allow_nonref/;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('+0') }; ok $@ =~ /malformed/;
eval { JSON::XS::Stable->new->allow_nonref->decode ('.2') }; ok $@ =~ /malformed/;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('bare') }; ok $@ =~ /malformed/;
eval { JSON::XS::Stable->new->allow_nonref->decode ('naughty') }; ok $@ =~ /null/;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('01') }; ok $@ =~ /leading zero/;
eval { JSON::XS::Stable->new->allow_nonref->decode ('00') }; ok $@ =~ /leading zero/;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('-0.') }; ok $@ =~ /decimal point/;
eval { JSON::XS::Stable->new->allow_nonref->decode ('-0e') }; ok $@ =~ /exp sign/;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ('-e+1') }; ok $@ =~ /initial minus/;
eval { JSON::XS::Stable->new->allow_nonref->decode ("\"\n\"") }; ok $@ =~ /invalid character/;
eval { JSON::XS::Stable->new->allow_nonref (1)->decode ("\"\x01\"") }; ok $@ =~ /invalid character/;
eval { JSON::XS::Stable->new->decode ('[5') }; ok $@ =~ /parsing array/;
eval { JSON::XS::Stable->new->decode ('{"5"') }; ok $@ =~ /':' expected/;
eval { JSON::XS::Stable->new->decode ('{"5":null') }; ok $@ =~ /parsing object/;

eval { JSON::XS::Stable->new->decode (undef) }; ok $@ =~ /malformed/;
eval { JSON::XS::Stable->new->decode (\5) }; ok !!$@; # Can't coerce readonly
eval { JSON::XS::Stable->new->decode ([]) }; ok $@ =~ /malformed/;
eval { JSON::XS::Stable->new->decode (\*STDERR) }; ok $@ =~ /malformed/;
eval { JSON::XS::Stable->new->decode (*STDERR) }; ok !!$@; # cannot coerce GLOB

eval { decode_json ("\"\xa0") }; ok $@ =~ /malformed.*character/;
eval { decode_json ("\"\xa0\"") }; ok $@ =~ /malformed.*character/;

