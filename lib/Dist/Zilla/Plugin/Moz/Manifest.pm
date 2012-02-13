package Dist::Zilla::Plugin::Moz::Manifest;
{
  $Dist::Zilla::Plugin::Moz::Manifest::VERSION = '0.102';
}
use Moose;
use File::Spec::Functions;
with 'Dist::Zilla::Role::FileGatherer';
use Dist::Zilla::File::InMemory;
use namespace::autoclean;

has overlay => (
    is        => 'ro',
    isa       => 'ArrayRef[Str]',
    predicate => 'has_overlay',
    default   => sub { [] },
);

has style => (
    is        => 'ro',
    isa       => 'ArrayRef[Str]',
    predicate => 'has_style',
    default   => sub { [] },
);

sub mvp_multivalue_args { return qw/overlay style/ }

sub gather_files {
    my ($self)  = @_;
    my $name    = $self->zilla->plugin_named("Moz")->name;
    my $useJar  = $self->zilla->plugin_named("Moz")->useJAR;
    my $x = $useJar ? "jar:chrome/${name}.jar!" : "chrome";
    my $content = <<"EOF";
content     $name                   $x/content/
skin        $name   classic/1.0     $x/skin/

EOF

    ## append locales
    my $dir = catfile("chrome", "locale");
    my @locales =
      map { (split /\//)[-1] } grep { -d $_ } glob(catfile($dir, "*"));
    for (@locales) {
        $content .= <<"EOF";
locale      $name   $_              $x/locale/$_
EOF
    }

    ## append atrributes
    if ($self->has_overlay) {
        for (@{$self->overlay}){
            my @xuls = split /\s+/, $_, 2;
            $content .= <<"EOF";
overlay     chrome:/$xuls[0]        chrome://${name}$xuls[1]
EOF
        }
    }

    if ($self->has_style) {
        for (@{$self->style}){
            my @xuls = split /\s+/, $_, 2;
            $content .= <<"EOF";
style       chrome:/$xuls[0]        chrome://${name}$xuls[1]
EOF
        }
    }

    $self->add_file(
        Dist::Zilla::File::InMemory->new(
            name => 'chrome.manifest',
            content => $content,
        )
    );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::Moz::Manifest 

=head1 VERSION

version 0.102

=head1 SYNOPSIS

    [Moz::Manifest]
    overlay = /browser/content/browser.xul /content/status-overlay.xul
    style = ....

=head1 DESCRIPTION

Set overylay and style for you chrome.manifest

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
