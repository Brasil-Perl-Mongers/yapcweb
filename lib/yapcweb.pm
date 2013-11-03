package yapcweb;

use Dancer ':syntax';
use Dancer::Plugin::I18N;
use Dancer::Plugin::Email;
use HTTP::AcceptLanguage;
use Dancer::Plugin::FlashMessage;

our $VERSION = '0.1';

prefix '/';

hook before_template => sub {
	my $tokens = shift;
	$tokens->{uri_base} = request->base->path eq '/' ? '' : request->base->path;	
	$tokens->{'index'}  = uri_for('/index');
};


get '/' => sub {
	# gets the language of preference from http request header
	# and sets the session variable
	my $accept_language = HTTP::AcceptLanguage->new(request->accept_language);
	session user_lang => $accept_language->languages;
	template 'index';
};

get '/premio' => sub {
    
    my %rank;

    open(my $prize_file, '<', 'public/docs/premio.txt') or die "** file not found **";

    while (my $line = <$prize_file>) {
        chomp $line;
        my @elems = split(/\#/, $line);
        $rank{$elems[0]} = $elems[1];
    }

	my @opts;

	foreach my $key (sort { $rank{$b} <=> $rank{$a} } keys (%rank)) {
		push(@opts, "$key#$rank{$key}");	
	}
	
    template 'prize' => {
    	name => \@opts,
    };
};

post '/premio' => sub {
	
	my $vote		= params->{radio_opt};
    my $candidate	= params->{candidate_opt};
	my $voter_name	= params->{voter_name};
	my $voter_rg	= params->{voter_rg};

	if ($voter_name && $voter_rg) {

		my %list;
		my $new_voter = "$voter_name#$voter_rg";
		open (my $read_file, '<', 'public/docs/premio_controle.txt') or die "** file not found **";

        while (my $line = <$read_file>) {
			
			chomp $line;
			$list{$line} = 1;
		}

		if (exists $list{$new_voter}) {
			
			flash warning => "Seu voto já foi registrado previamente! Obrigado pela participação.";
			return redirect '/premio';

		} else {
			
			open (my $write_file, '>>', 'public/docs/premio_controle.txt') or die "** file not found **";
			print $write_file "$new_voter\n";

		}

	    if ($vote) {
	        
	        chomp $vote;
	        open(my $prize_file, '<', 'public/docs/premio.txt') or die "** file not found **";
		   	my %rank;
	
	        while (my $line = <$prize_file>) {
	    		
				chomp $line;
	    		my @elems = split(/\#/, $line);
	            $rank{$elems[0]} = $elems[1];
	    
	    		if ($elems[0] eq $vote) {
	    			$rank{$elems[0]} = ($elems[1] + 1);
	            }
	    	}
    
    		open(my $write_file, '>', 'public/docs/premio.txt') or die "** file not found **";
    
	    	while ( my ($key, $value) = each %rank ) {
	            chomp $key;
	            chomp $value;
	    		print $write_file "$key#$value\n";
	    	}
	
	    } elsif ($candidate) {
	
	        chomp $candidate;
	        open(my $write_file, '>>', 'public/docs/premio.txt') or die "** file not found **";
	        print $write_file "$candidate#1\n";
	
	    }

		flash warning => "Seu voto foi registrado! Obrigado pela participação.";
	    redirect '/premio';

	} else {
		return redirect '/premio';
	}
};


get '/talk/:id' => sub {
	my $page = param('id') || 'empty';
	template "$page";
};


get qr{/(?<lang> pt | en)}x, sub {
	# changes the prefered language by demand
	my $captures = captures;
	session user_lang => $$captures{lang};
	template 'index';
};

post qr{/(?<lang> .*)}x, sub {
	#my $opt_lang = ( param('opt_lang') || 'empty' );
	my $captures = captures;
	my $opt_lang = $$captures{lang};

	if ($opt_lang !~ m/\w/g) {
		$opt_lang = 'empty';
	}

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
			subject	=> '[YAPC] Nova Palestra',
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



