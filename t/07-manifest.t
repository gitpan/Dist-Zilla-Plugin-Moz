use strict;
use warnings;

use Test::More tests => 2;
use Test::DZil;
use Path::Class;
use File::Spec::Functions;

my $ini = simple_ini(
    'GatherDir',
    [   Moz => {
            contributor => ['contributors', 'redicaps'],
            id          => 'uniqName@gmail.com',
            type        => 2,
            maxVersion  => '11.*',
            minVersion  => '0.3',
            useJAR      => 1,
        },
    ],
    [   'Moz::Manifest' => {
            overlay =>
              ['/browser/content/browser.xul /content/status-overlay.xul'],
            style =>
              ['/global/content/customizeToolbar.xul /skin/overlay.css'],
        }
    ]
);
my $tzil = Builder->from_config(
    {dist_root => 't/corpus/DZT'},
    {add_files => {'source/dist.ini' => $ini,},},
);

$tzil->build;
my $built_in = $tzil->built_in;
my $content = $tzil->slurp_file(catfile("build", "chrome.manifest"));

is(-e file($built_in, "chrome", 'uniqName.jar') . "", 1);
cmp_ok($content, "eq", <<"EOF");
content     uniqName                   jar:chrome/uniqName.jar!/content/
skin        uniqName   classic/1.0     jar:chrome/uniqName.jar!/skin/

overlay     chrome://browser/content/browser.xul        chrome://uniqName/content/status-overlay.xul
style       chrome://global/content/customizeToolbar.xul        chrome://uniqName/skin/overlay.css
EOF
