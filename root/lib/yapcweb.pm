package yapcweb;

use Dancer ':syntax';
use Dancer::Plugin::I18N;
use HTTP::AcceptLanguage;

use Data::Printer;

our $VERSION = '0.1';

prefix '/';

hook before_template => sub {
	my $tokens = shift;
	$tokens->{uri_base} = request->base->path eq '/' ? '' : request->base->path;	
	$tokens->{'index'}  = uri_for('/');
};


get '/' => sub {

	#my $accept_language = HTTP::AcceptLanguage->new(request->accept_language);
	my $accept_language = 'pt';
	session user_lang => $accept_language;
	template 'index';
};

true;
