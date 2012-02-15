package Dist::Zilla::Plugin::Moz::InstallRDF;
{
  $Dist::Zilla::Plugin::Moz::InstallRDF::VERSION = '0.104';
}
use Moose;
use Template::Declare;
use Dist::Zilla::File::InMemory;
use MooseX::Types -declare => [qw/badURL/];
use MooseX::Types::Common::String 'NonEmptySimpleStr';
with 'Dist::Zilla::Role::FileGatherer';
use namespace::autoclean;

subtype badURL, 
    as NonEmptySimpleStr,
    where { $_ =~ m$^/$},
    message { "URL should start with /"};
has optionsURL => (
    is        => 'rw',
    isa       => badURL,
    predicate => 'has_options',
    clearer   => 'clear_options'
);

has iconURL => (
    is        => 'rw',
    isa       => badURL,
    predicate => 'has_icon',
    clearer   => 'clear_icon',
);

has homepageURL => (
    is        => 'rw',
    isa       => badURL,
    predicate => 'has_homepage',
    clearer   => 'clear_homepage',
);

has aboutURL => (
    is        => 'rw',
    isa       => badURL,
    predicate => 'has_about',
    clearer   => 'clear_about',
);

sub gather_files {
    my ($self) = @_;

    Template::Declare->init(
        dispatch_to => ['Dist::Zilla::Plugin::Moz::InstallRDF::Template']);
    my $file = Template::Declare->show('install.rdf', $self);

    $self->add_file(
        Dist::Zilla::File::InMemory->new(
            name    => 'install.rdf',
            content => $file
        )
    );
}

__PACKAGE__->meta->make_immutable;

package Dist::Zilla::Plugin::Moz::InstallRDF::Template;
{
  $Dist::Zilla::Plugin::Moz::InstallRDF::Template::VERSION = '0.104';
}
use Template::Declare::Tags 'RDF::EM' => {namespace => 'em'}, 'RDF';
use base 'Template::Declare';

template 'install.rdf' => sub {
    my $self = shift;
    my $obj  = shift;

    my $zilla = $obj->zilla;
    my $moz   = $zilla->plugin_named("Moz");
    my $optionsURL;

    xml_decl { 'xml', version => '1.0', encoding => "UTF-8"};
    RDF {
        attr {
            'xmlns'    => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            'xmlns:em' => 'http://www.mozilla.org/2004/em-rdf#'
          }
        Description {
            attr {about => 'urn:mozilla:install-manifest'} em::id { $moz->id }
            em::type { $moz->type }
            em::name { $zilla->name }
            em::version { $zilla->version }
            em::creator { $zilla->authors->[0] }
            em::contributor { join ",", @{$moz->contributor} };

            foreach (qw/options icon about homepage/) {
                my $has = "has_" . $_;
                if ($obj->$has) {
                    my $url = $_ . "URL";
                    my $v = $obj->$url;
                    my $str = "em::$url {'chrome://" . $moz->name . "${v}'}";
                    eval $str;
                }
            }
            em::description { $zilla->abstract };
            em::targetApplication {
                Description {
                    em::id {'{ec8030f7-c20a-464f-9b0e-13a3a9e97384}'}
                    em::minVersion { $moz->minVersion }
                    em::maxVersion { $moz->maxVersion }
                }
            }
        }
    };
};

1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::Moz::InstallRDF

=head1 VERSION

version 0.104

=head1 SYNOPSIS
    
    #dist.ini
    [Moz::InstallRDF]
    optionsURL = /content/options.xul
    iconURL =   /content/icon.png
    homepageURL = http://homepage.org
    aboutURL = http://about.org
    
=head1 DESCRIPTION

Set extra information for your install.rdf. You should set the
optionsURL and iconURL without the "chrome://addonsName' part

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
