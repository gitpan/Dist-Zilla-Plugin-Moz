package Dist::Zilla::MintingProfile::Moz;
{
  $Dist::Zilla::MintingProfile::Moz::VERSION = '0.101';
}

use Moose;
use namespace::autoclean;

with 'Dist::Zilla::Role::MintingProfile::ShareDir';

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME Dist::Zilla::MintingProfile::Moz


=head1 VERSION

version 0.101
Dist::Zilla::MintingProfile::Moz - minting profile provider for Mozilla
addons development

=head1 DESCRIPTION

This provider is shipped when you use 'dzil new -P Moz -p moz'

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
