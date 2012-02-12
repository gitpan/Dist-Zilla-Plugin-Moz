package Dist::Zilla::Plugin::Moz::Minter;
{
  $Dist::Zilla::Plugin::Moz::Minter::VERSION = '0.101';
}

# ABSTRACT: Default "minter" for Moz.pm
use Moose;
extends 'Dist::Zilla::Plugin::GatherDir::Template';
with 'Dist::Zilla::Role::FilePruner';

sub prune_files{
    my $self = shift;
    my $files = $self->zilla->files;
    @$files = grep { $_->name !~ m/profile.ini|.*\.pm$/} @$files;
    return;
}


1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::Moz::Minter - Minter for DZIL::P::Moz

=head1 VERSION

version 0.101

=head1 SYNOPSIS

    #profile.ini
    Moz::Minter

=head1 DESCRIPTION

This is the minter for Dist::Zilla::Plugin::Moz

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
