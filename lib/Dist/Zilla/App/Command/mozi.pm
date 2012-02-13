package Dist::Zilla::App::Command::mozi;
{
  $Dist::Zilla::App::Command::mozi::VERSION = '0.102';
}
use warnings;
use strict;
use Carp qw/croak/;
use File::Copy;
use Path::Class;

# ABSTRACT: install your addons to firefox profile for test
use Dist::Zilla::App -command;

sub abstract {"install your addons to firefox"}

sub execute {
    my ($self, $opt, $args) = @_;
    my $ext_dir = $opt->{extDir}
      || $self->zilla->plugin_named("Moz::Install")->extDir;
    if (!$ext_dir) {
        $self->log_fatal("firefox extension directory missing");
    } else {
        croak("direcotry: $ext_dir not found") unless -d $ext_dir;
    }

    my $pid = $self->zilla->plugin_named("Moz")->id;
    my $id = file($ext_dir, $pid);
    if ($opt->{test}) {
        $self->zilla->plugin_named("Moz")->useJAR(0);
        $self->zilla->ensure_built_in;

        open my $fh, ">", "$id" or croak $!;
        my $x = file($self->zilla->built_in, "a") . "";
        chop $x;
        print $fh $x;
        close $fh or croak $!;
        $self->log("$id created in $ext_dir");
    } else {
        $self->zilla->build_archive unless $self->zilla->{ensure_built_archive};
        my $name = $self->zilla->archive_filename;
        copy("$name", "$id" . ".xpi");
        $self->log("$id" .".xpi created in $ext_dir");
    }
}

sub opt_spec {
    ['test' => 'test install', {default => 0}],
    ['dir' => 'firefox extension directroy'],
}

1;

__END__

=pod

=head1 NAME

Dist::Zilla::App::Command::mozi - install your addons to firefox profile for test

=head1 VERSION

version 0.102

=head1 SYNOPSIS

dzil mozi [ --test --dir 'firefox extension dir' ]

=head1 DESCRIPTION

This command will install your built addon to firefox profile. It will
create a proxy file to your built addon directroy if you set --test in
the command line. Your should set the firefox extension directory in the
dist.ini [Moz] section or set it with '--dir'.

When you use it with no '--test', your addons will be packed into a
'.xpi' file and installed to the extnsion directory.

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
