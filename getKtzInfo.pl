#package EpayRailwaysKZ;

use strict;
use warnings;
use vars;
use feature qw (say switch);
use Getopt::Std;
use Net::SSL;
use LWP;
use HTML::Parser;
use Data::Dumper;
use Color::Output;
use Term::ReadKey;
use URI::Escape;

#Отключаем предупреждения если Perl >= 5.18
no if $] >= 5.018, warnings => "experimental::smartmatch";

our $screen_clear;

if ($^O =~ /MSWin32/) {
    $screen_clear = "cls"; 
    $ENV{PATH} = $ENV{PATH}.';C:\Windows\system32';
}
else {
    
    $screen_clear = "clear";
}

our ($URL_FROM_TO_BY_DATE, $ALL_STATIONS);

#Путь отправления, назначения, дата.
$ALL_STATIONS = 'https://epay.railways.kz/ktz4/json4.jsp?term='; #Все возможные варианты станций
#$URL_FROM_TO_BY_DATE = 'https://epay.railways.kz/ktz3/proc?pa=express3&sa=GET_P62G60_EVENT&STEP=2&TIME=&FROM_STATION_LIST=1960&TO_STATION_LIST=1425&DATE=05.01.2013';
$URL_FROM_TO_BY_DATE = 'https://epay.railways.kz/ktz4/proc?pa=express3&sa=GET_P62G60_EVENT&STEP=1&TIME=&FROM_STATION=%D0%90%D0%A1%D0%A2%D0%90%D0%9D%D0%90%282708000%29&TO_STATION=%D0%AD%D0%BA%D0%B8%D0%B1%D0%B0%D1%81%D1%82%D1%83%D0%B7-1%282708990%29&DATE=11.07.2014';

#my %OPTS_URL_FROM_TO_BY_DATE = {'pa' => 'express',
#                           
#                           'sa' => 'GET_P62G60_EVENT',
#                           
#                           'STEP' => 2,
#                           
#                           'TIME' => '',
#                           
#                           'FROM_STATION_LIST' => 1960,
#                           
#                           'TO_STATION_LIST' => 1425,
#                           
#                           'DATE' => '05.01.2013'
#                           
#                          }; 

###############################################################################################################
#Эти определния ДОЛЖНЫ быть, если требуется работать с HTTPS через прокси сервер
#Если требуется работать с HTTP через прокси, то смотреть $ua->proxy( ['http'], 'http://host:port' );
#Баг с LWP (работа с HTTPS через прокси)
#Пропатчен strawberry perl согласно вот этого - https://rt.cpan.org/Public/Bug/Display.html?id=1894
####################################################
#$Net::HTTPS::SSL_SOCKET_CLASS = "Net::SSL";       #
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;            #
$ENV{HTTPS_DEBUG} = 1;                             #
$ENV{HTTPS_VERSION} = '3';   					   #	
#$ENV{HTTPS_VERSION} = '3';                        #
#$ENV{HTTPS_CA_FILE} = 'CA.crt';                   #
####################################################

#Define LWP global vars
our ($ua, $res, $req);

# Check proxy option
my ($proxy_username, $proxy_password, $proxyport);

our ($opt_p, $opt_L);

getopt('pL:');


    if ( defined($opt_p) && $opt_p =~ /^\w*:*\w*@*[^\W](((\d{1,3}\.{1}){3}\d{1,3}:\d{1,5})|((([\w\.]))+[^\W]:\d{1,5}))/i ) {
    
        if ($opt_p =~ /@/) { #Proxy was defined as user:pass@host:port
            $proxy_username, $proxy_password = split /:/, $`;
            $proxyport = $';
                $ENV{HTTPS_PROXY}  = $proxyport; 
                $ENV{HTTPS_PROXY_USERNAME} = $proxy_username;
                $ENV{HTTPS_PROXY_PASSWORD} = $proxy_password;
        }
        else {  #Proxy was defined as host:port 
            $proxyport = $opt_p;
            $ENV{HTTPS_PROXY}  = $proxyport;
        }
              
                #Define UserAgent
                $ua = LWP::UserAgent->new();
                $ua->agent('User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0');
                $ua->show_progress('false');

                defined ($proxyport) ? $ua->proxy('http', ('http://'.$proxyport)) : say ('Connection without PROXY:PORT');
    }
    elsif ( defined($opt_p) ) {
        
        say 'Incorrect proxy format. Please, define proxy as user:password@host:port';
        exit;
    }


#Check request's level option 

    given ($opt_L) {
        when (!defined($opt_L)) {&Help;};
        when ($opt_L =~ /1/) {&Func1};
        when ($opt_L =~ /2/) {&Func2};
        when ($opt_L =~ /3/) {&Func3};
        when ($opt_L =~ /4/) {&GetAllStations};
        default              {&Help};
    }


#my $req = HTTP::Request->new( 'GET' => $URL_FROM_TO_BY_DATE );
#my $res = $ua->request($req);
#$res->is_success or die "$URL_FROM_TO_BY_DATE: ", $res->message, "\n"; 
#say $res->as_string;

my $content; 
   
#$content = HTML::Parser->new (
#                                api->version => 3,
#                                start_h => [\&start, ]
#        
#                            );
# 
sub GetAllStations {
   
        my %stationsList;

        $req = HTTP::Request->new( 'GET' => $ALL_STATIONS );
        $res = $ua->request($req);
        $res->is_success or die "$ALL_STATIONS : ", $res->message, "\n"; 
        say $res->as_string;
        
        

}

sub Func1 {
    
        $req = HTTP::Request->new( 'GET' => $URL_FROM_TO_BY_DATE );
        $res = $ua->request($req);
        $res->is_success or die "$URL_FROM_TO_BY_DATE: ", $res->message, "\n"; 
        say $res->as_string;
    };

say uri_unescape("%D0%90%D0%A1%");
say uri_escape("АС");

sub Func2 {say 'Func2'};
sub Func3 {say 'Func3'};
sub Help {

print <<HELP;

Avliable options:
            -p  -  Defenition proxy connection options. Must be user:pass\@host:port or host:port.
            -L  -  Request level. Must be 1 or 2 or 3. Example -L1, -L2, -L3.
                   Where:
                     
                     1 - Get information about avalible trip's.
                     2 - Get detail infromation about all availiable trip's.
                     3 - Other.

HELP

exit 1;
};
