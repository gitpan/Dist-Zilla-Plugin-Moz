use strict;
use warnings;

package xx;
{
    use Moose;
    has zilla => (is => 'rw');

    sub log {
        my $self = shift;
        $self->zilla->log(@_);
    }
}

package main;
use Test::More tests => 2;
use Test::DZil;
use File::Spec::Functions;
use Dist::Zilla::App::Command::mozi;
use Path::Class;

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
            overlay =>
              ['/browser/content/browser.xul /content/status-overlay.xul'],
            style =>
              ['/global/content/customizeToolbar.xul /skin/overlay.css'],
        }
    ],
    ['Moz::Archive'],
    ['Moz::Install' => {extDir => "."}]

);
my $tzil = Builder->from_config(
    {dist_root => 't/corpus/DZT'},
    {add_files => {'source/dist.ini' => $ini,},},
);

my $tapp = xx->new(zilla => $tzil);
Dist::Zilla::App::Command::mozi::execute($tapp, {test => 1});
my $name = 'uniqName@gmail.com';

is(-e $name, 1);

my $content = do {
    use autodie;
    local $/;
    open my $fh, '<', $name;
    <$fh>;
};

my $x = file($tzil->built_in, "a") . "";
chop $x;
cmp_ok("$x", "eq", $content);

unlink $name;
