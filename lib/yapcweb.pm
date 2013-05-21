package yapcweb;

use Dancer ':syntax';
use Dancer::Plugin::I18N;
use Dancer::Plugin::Email;
use HTTP::AcceptLanguage;

our $VERSION = '0.1';

prefix '/';

hook before_template => sub {
	my $tokens = shift;
	$tokens->{uri_base} = request->base->path eq '/' ? '' : request->base->path;	
	$tokens->{'index'}  = uri_for('/');
};


get '/' => sub {

	# gets the language of preference from http request header
	# and sets the session variable
	my $accept_language = HTTP::AcceptLanguage->new(request->accept_language);
	session user_lang => $accept_language->languages;
	
	template 'index';
};

get '/:opt_lang' => sub {

	# changes the prefered language by demand
	my $opt_lang = param('opt_lang');
	session user_lang => $opt_lang;

	template 'index';
};

post '/:opt_lang?' => sub {

	my $opt_lang = ( param('opt_lang') || 'empty' );

	# verify if the "captcha" in the form is correct
	if (params->{verificaPalestrante} eq '5') {

		my %talk;

		$talk{name}		= params->{nomePalestrante};
		$talk{email}	= params->{emailPalestrante};
		$talk{dia}		= params->{diaPalestrante};
		$talk{tempo}	= params->{tempoPalestrante};
		$talk{title}	= params->{tituloPalestrante};
		$talk{abstract}	= params->{resumoPalestrante};
	
		# para a organização
		email {
			from 	=> 'mailer@hexabio.com.br',
			to   	=> 'yapc-curitiba@googlegroups.com',
			subject	=> 'Nova Palestra',
			body	=> "Nome: $talk{name}\nE-mail: $talk{email}\nDia de preferência: $talk{dia}\nDuração: $talk{tempo}\nTítulo: $talk{title}\nResumo: $talk{abstract}\n",
		};

		if ($opt_lang eq 'pt') {

			# para o palestrante brasileiro
		    email {
		        from    => 'mailer@hexabio.com.br',
		        to      => "$talk{email}",
		        subject => 'Palestra Enviada',
		        body    => "Olá $talk{name}!\nSua palestra entitulada: \'$talk{title}\' foi enviada com sucesso.\n\nIremos avaliar sua proposta e logo retornaremos uma resposta.",
		    };
	        
		} else {
			
			# para o palestrante de fora
			email {
				from    => 'mailer@hexabio.com.br',
				to      => "$talk{email}",
				subject => 'Talk submitted',
				body    => "Hello $talk{name}!\nYour talk entitled: \'$talk{title}\' was successfully submitted.\n\nAfter evaluation we will return to you with an answer.\n",
			};
		}
	}

	return redirect "/";

};

true;
