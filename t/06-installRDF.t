use strict;
use warnings;

use Test::More;
use Test::DZil;

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
    [   'Moz::InstallRDF' => {
            optionsURL => '/content/options.xul',
            iconURL    => '/content/icon.png'
        }
    ]

);

my $tzil = Builder->from_config(
    {dist_root => 't/corpus/DZT'},
    {add_files => {'source/dist.ini' => $ini,},},
);

$tzil->build;
my $content = $tzil->slurp_file("build/install.rdf");

cmp_ok("$content\n", "eq", <<'EOF');
<?xml version="1.0" encoding="UTF-8"?>

<RDF xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:em="http://www.mozilla.org/2004/em-rdf#">
 <Description about="urn:mozilla:install-manifest">
  <em:id>uniqName@gmail.com</em:id>
  <em:type>2</em:type>
  <em:name>DZT-Sample</em:name>
  <em:version>0.001</em:version>
  <em:creator>E. Xavier Ample &lt;example@example.org&gt;</em:creator>
  <em:contributor>contributors,redicaps</em:contributor>
  <em:optionsURL>chrome://uniqName/content/options.xul</em:optionsURL>
  <em:iconURL>chrome://uniqName/content/icon.png</em:iconURL>
  <em:description>Sample DZ Dist</em:description>
  <em:targetApplication>
   <Description>
    <em:id>{ec8030f7-c20a-464f-9b0e-13a3a9e97384}</em:id>
    <em:minVersion>0.3</em:minVersion>
    <em:maxVersion>11.*</em:maxVersion>
   </Description>
  </em:targetApplication>
 </Description>
</RDF>
EOF
done_testing;

