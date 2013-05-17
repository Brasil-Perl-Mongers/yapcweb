package yapcweb;

use Dancer ':syntax';
use Dancer::Plugin::I18N;
use HTTP::AcceptLanguage;

our $VERSION = '0.1';

prefix '/';

hook before_template => sub {
	my $tokens = shift;
	$tokens->{uri_base} = request->base->path eq '/' ? '' : request->base->path;	
	$tokens->{'index'}  = uri_for('/');
};


get '/' => sub {

	my $accept_language = HTTP::AcceptLanguage->new(request->accept_language);
	session user_lang => $accept_language;
	
	template 'index';
};


get '/:opt_lang' => sub {

	my $opt_lang = param('opt_lang');
	session user_lang => $opt_lang;

	template 'index';
};

true;
