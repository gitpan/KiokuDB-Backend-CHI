package KiokuDB::Backend::CHI;
BEGIN {
  $KiokuDB::Backend::CHI::VERSION = '0.01';
}

# ABSTRACT: CHI backend for KiokuDB

use Moose;

use CHI;
use Data::Stream::Bulk::Array;

with qw/
  KiokuDB::Backend
  KiokuDB::Backend::Serialize::Delegate
  KiokuDB::Backend::Role::Clear
  KiokuDB::Backend::Role::Scan
/;

has cache => (
  is       => 'ro',
  isa      => 'Object',
  lazy     => 1,
  required => 1,
  builder  => '_build_cache',
);

has check_duplicates => (
  is      => 'ro',
  isa     => 'Bool',
  default => 1,
);

sub _build_cache {
  my ($self) = @_;

  return CHI->new (driver => 'Memory',datastore => {});
}

sub insert {
  my ($self,@entries) = @_;

  if ($self->check_duplicates) {
    my @create = map { $_->id } grep { ! $_->has_prev } @entries;

    confess "Cannot insert duplicate key" if scalar grep { $_ } $self->exists (@create);
  }

  $self->cache->set_multi ({ map { $_->id => $self->serialize ($_) } @entries });

  return;
}

sub delete {
  my ($self,@ids_or_entries) = @_;

  my @ids = map { ref ($_) ? $_->id : $_ } @ids_or_entries;

  $self->cache->remove_multi (\@ids);

  return;
}

sub get {
  my ($self,@ids) = @_;

  return map { defined $_ ? $self->deserialize ($_) : undef } @{ $self->cache->get_multi_arrayref (\@ids) };
}

sub exists {
  my ($self,@ids) = @_;

  return $self->cache->is_valid (@ids) if scalar @ids == 1;

  return map { ! ! $_ } $self->get (@ids);
}

sub all_entries {
  my ($self) = @_;

  my @entries = map { $self->deserialize ($_) } grep { defined $_ } values %{ $self->cache->dump_as_hash };

  return Data::Stream::Bulk::Array->new (array => \@entries);
}

sub clear {
  my ($self) = @_;

  $self->cache->clear;

  return;
}

1;



__END__
=pod

=head1 NAME

KiokuDB::Backend::CHI - CHI backend for KiokuDB

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  my $dir = KiokuDB->new(
    backend => KiokuDB::Backend::CHI->new(
      cache => CHI->new(driver => 'Memory',datastore => {}),
    ),
  );

=head1 DESCRIPTION

A more detailed description will come later, but the module should
hopefully be self-explanatory enough for the purposes of testing.

=head1 BUGS

Most software has bugs. This module probably isn't an exception. 
If you find a bug please either email me, or add the bug to cpan-RT.

=head1 AUTHOR

  Anders Nor Berle <berle@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Anders Nor Berle.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

