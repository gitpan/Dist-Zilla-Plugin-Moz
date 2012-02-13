package Dist::Zilla::Plugin::Moz::Install;
{
  $Dist::Zilla::Plugin::Moz::Install::VERSION = '0.102';
}
use Moose;
use Carp qw/croak/;
use MooseX::Types -declare => ['RealDir'];
use MooseX::Types::Common::String 'NonEmptySimpleStr';
use Path::Class;
with "Dist::Zilla::Role::AfterBuild";

subtype RealDir, as 'Path::Class::Dir';

coerce RealDir, from NonEmptySimpleStr, via {
    !-e $_ && croak "$_ does not exist";
    dir($_);
};

has extDir => (
    is  => 'rw',
    isa => RealDir,
    coerce => 1,
);



sub after_build { }
1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::Moz::Install

=head1 VERSION

version 0.102

=head1 SYNOPSIS

    #dist.ini
    [Moz::Install]
    extDir => 'firefox extension directory'

=head1 DESCRIPTION
    
This is where you can set where you want to install your distribution
when you use 'dzil install'

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
