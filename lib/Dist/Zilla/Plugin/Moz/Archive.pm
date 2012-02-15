package Dist::Zilla::Plugin::Moz::Archive;
{
  $Dist::Zilla::Plugin::Moz::Archive::VERSION = '0.104';
}

# ABSTRACT: generate .xpi for your dist

use Moose;
use Archive::Zip qw/:ERROR_CODES :CONSTANTS/;
use Moose::Autobox;
use Dist::Zilla::Dist::Builder;
use Path::Class;
with "Dist::Zilla::Role::BeforeArchive";
no warnings 'redefine';

*Dist::Zilla::Dist::Builder::build_archive = sub {
    my ($self)   = @_;
    my $built_in = $self->ensure_built;
    my $basename = $self->dist_basename;
    my $basedir  = dir($basename);

    $_->before_archive for $self->plugins_with(-BeforeArchive)->flatten;

    our $archive = Archive::Zip->new();

    my %seen_dir;
    for my $distfile (sort { length($a->name) <=> length($b->name) }
        $self->files->flatten)
    {
        my $in = file($distfile->name)->dir;

        unless ($seen_dir{$in}++) {
            $archive->addDirectory($basedir->subdir($in));
        }

        my $filename = $built_in->file($distfile->name);
        my $content  = do {
            use autodie;
            local $/;
            open my $fh, '<', $filename;
            <$fh>;
        };

        my $file = $basedir->file($distfile->name);
        $archive->addString($content, "$file");
    }

    my $file = file($self->archive_filename);
    $self->log("writing archive to $file");
    unless ($archive->writeToFileNamed("$file") == AZ_OK) {
        $self->log_fatal("writting $file error");
    }
    $self->{ensure_built_archive} = $file;
    return $file;
};

*Dist::Zilla::Dist::Builder::archive_filename = sub {
    my ($self) = @_;
    return join(q{}, $self->dist_basename, '.xpi');
};

sub before_archive { }

1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::Moz::Archive

=head1 VERSION

version 0.104

=head1 SYNOPSIS

    #dist.ini
    [Moz::Archive]

=head1 DESCRIPTION

Pack your dist into a firefox '.xpi' file when you use 'dzil build'

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COYPRIGHT

his software is copyright (c) 2012 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
