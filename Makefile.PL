use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'yapcweb',
    AUTHOR              => q{Felipe da Veiga Leprevost <leprevost@cpan.org>},
    VERSION_FROM        => 'lib/yapcweb.pm',
    ABSTRACT            => 'This is the YAPC::Brasil webserver',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' 				=> 0,
        'YAML'       				=> 0,
        'Dancer'     				=> 0,
		'Plack'	     				=> 0,
		'Plack::Request' 			=> 0,
		'Template'   				=> 0,
		'HTTP::AcceptLanguage'		=> 0,
		'Dancer::Plugin::I18N'		=> 0,
		'Dancer::Plugin::Email'		=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'yapcweb-*' },
);
