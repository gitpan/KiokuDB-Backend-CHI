
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'CHI backend for KiokuDB',
  'AUTHOR' => 'Anders Nor Berle <berle@cpan.org>',
  'BUILD_REQUIRES' => {
    'KiokuDB' => '0',
    'KiokuDB::Test' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'KiokuDB-Backend-CHI',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'KiokuDB::Backend::CHI',
  'PREREQ_PM' => {
    'CHI' => '0',
    'Data::Stream::Bulk::Array' => '0',
    'KiokuDB::Backend' => '0',
    'KiokuDB::Backend::Role::Clear' => '0',
    'KiokuDB::Backend::Role::Scan' => '0',
    'KiokuDB::Backend::Serialize::Delegate' => '0',
    'Moose' => '0'
  },
  'VERSION' => '0.01',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM}; 
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod}; 
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



