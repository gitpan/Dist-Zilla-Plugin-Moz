use strict;
use warnings;

use Test::More tests => 2;
use Test::DZil;

my $ini = simple_ini(
    'GatherDir',
    [   
        Moz => {
            contributor => ['contributors', 'redicaps'],
            id          => 'uniqName@example.com',
            type        => 2,
            maxVersion  => '11.*',
            minVersion  => '0.3',
        },
    ]
);
my $tzil = Builder->from_config(
    {dist_root => 't/corpus/DZT'},
    {add_files => {'source/dist.ini' => $ini,},},
);

my $moz = $tzil->plugin_named('Moz');
is($moz->type, 2);
cmp_ok($moz->maxVersion, "eq", "11.*");
