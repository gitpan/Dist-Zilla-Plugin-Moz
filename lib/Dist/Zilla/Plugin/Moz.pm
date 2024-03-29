package Dist::Zilla::Plugin::Moz;
{
  $Dist::Zilla::Plugin::Moz::VERSION = '0.104';
}

# ABSTRACT: Dist::Zilla plugin for firefox development
use Moose;
use Moose::Autobox;
use MooseX::Types::Email qw/EmailAddress/;
use Moose::Util::TypeConstraints;
use Archive::Zip;
use File::Spec;
use Path::Class;
use Dist::Zilla::File::InMemory;
with 'Dist::Zilla::Role::FileGatherer';

use namespace::autoclean;
has 'contributor' => (
    isa     => 'ArrayRef[Str]',
    is      => 'ro',
    default => sub { [] },
);

has useJAR => (
    is      => 'rw',
    isa     => enum([qw/1 0/]),
    default => 0,
);

has 'type'       => (is => 'ro', isa => 'Int', default => 2);
has 'maxVersion' => (is => 'ro', isa => 'Str', default => '0.3');
has 'minVersion' => (is => 'ro', isa => 'Str', default => '11.*');
has 'id' => (is => 'ro', isa => EmailAddress, required => 1);
has 'name' => (is => 'rw', isa => 'Str');

sub BUILD {
    my ($self) = @_;
    $self->name((split qr/@/, $self->id)[0]);
}

sub mvp_multivalue_args { return qw'contributor' }

sub gather_files {
    my ($self, $opt) = @_;
    if ($self->useJAR) {
        my $archive = Archive::Zip->new();
        my $jar_content;
        open my $fh, ">", \$jar_content or die $!;
        my $filename = file("chrome", $self->name . ".jar");
        $archive->writeToFileNamed("$filename");

        my @files = $self->zilla->files->flatten;
        for my $distfile (@files) {
            if (dir("chrome")->subsumes($distfile->name)) {
                $self->zilla->prune_file($distfile);
                my @dirs = File::Spec->splitdir($distfile->name);
                shift @dirs;
                $archive->addString($distfile->content, file(@dirs). "");
            }

        }
        $archive->writeToFileHandle($fh);
        close $fh;
        $self->add_file(
            Dist::Zilla::File::InMemory->new(
                name    => "$filename",
                content => $jar_content,
            )
        );
    }
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME 

Dist::Zilla::Plugin::Moz - Dist::Zilla plugin for your firefox addons development

=head1 VERSION

version 0.104

=head1 SYNOPSIS

in your dist.ini
    
    [Moz]
    id                  = appUniqName@example.com
    contributor         = some contributors
    type                = 2
    maxVersion          = 11.*
    minVersion          = 0.3
    useJAR              = 1
    [Moz::Manifest]
    overlay =  /browser/content/browser.xul /content/status-overlay.xul
    style   =  /global/content/customizeToolbar.xul     /skin/overlay.css
    [Moz::InstallRDF]
    optionsURL = content/options.xul
    [Moz::Archive]
    [Moz::Install]
    extDir = /home/yourid/.mozilla/firefox/8ywcrpsn.default/extensions/


=head1 DESCRIPTION

Dist::Zilla::Plugin::Moz is created for firefox addons developement. It
can do those work for you.

=over

=item create addons template

ship L<Dist::Zilla::MintingProfile::Moz> when you use 'dzil new -P Moz
-p moz'

=item generate install.rdf

see L<Dist::Zilla::Plugin::Moz::InstallRDF>

=item generate chrome.manifest

see L<Dist::Zilla::Plugin::Moz::Manifest>

=item build addons arvhive

see L<Dist::Zilla::Plugin::Moz::Archive>

=item install addons

see L<Dist::Zilla::Plugin::Moz::Install>

=back

=head1 SETTINGS 

=over 

=item id

This is a uniq id for your addons, you should set is as an email form.

=item type 

default to 2

=item contributor

=item minVersion

=item maxVersion

=item useJAR

setting useJAR in this section will pack the content into a $name.jar and
make correspond changes in chrome.manifest

=back

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
