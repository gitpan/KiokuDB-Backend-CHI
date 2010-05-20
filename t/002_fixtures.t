use Test::More 'no_plan';
use KiokuDB::Test;

use KiokuDB;
use KiokuDB::Backend::CHI;

use strict;
use warnings;

my $b = KiokuDB::Backend::CHI->new;

run_all_fixtures (KiokuDB->new (backend => $b));

