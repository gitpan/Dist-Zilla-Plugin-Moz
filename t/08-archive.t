use strict;
use warnings;

use Test::More tests => 1;
use Test::DZil;
use File::Spec::Functions;

my $ini = simple_ini(
    'GatherDir',
    [   Moz => {
            contributor => ['contributors', 'redicaps'],
            id          => 'uniqName@gmail.com',
            type        => 2,
            maxVersion  => '11.*',
            minVersion  => '0.3',
        },
    ],
    [   'Moz::Manifest' => {
            overlay => [
                '/browser/content/browser.xul /content/status-overlay.xul'
            ],
            style => [
                '/global/content/customizeToolbar.xul /skin/overlay.css'
            ],
        }
    ],
    [ 'Moz::Archive' ],
);
my $tzil = Builder->from_config(
    {dist_root => 't/corpus/DZT'},
    {add_files => {'source/dist.ini' => $ini,},},
);
$tzil->build_archive;

is(-e "DZT-Sample-0.001.xpi", 1);
unlink("DZT-Sample-0.001.xpi");
