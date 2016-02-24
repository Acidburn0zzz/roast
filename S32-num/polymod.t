use v6.c;
use Test;
plan 4;

# L<S32::Numeric/=item polymod>

is 86400.polymod(60),       (0,1440),  '86400 60';
is 86400.polymod(60,60),    (0,0,24),  '86400 60 60';
is 86400.polymod(60,60,24), (0,0,0,1), '86400 60 60 24';

is 1234567890.polymod(10 xx *), (0,9,8,7,6,5,4,3,2,1), '1234567890 10 xx *';
