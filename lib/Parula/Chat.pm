package Chat;

use strict;
use warnings;

use REST::Client;
use JSON::PP;
use HTML::Entities;
use URI::Escape; 
use CGI qw(:standard);
use Encode qw(decode encode);

use Config::Config;
use Parula::Db;
use Parula::Utils;
use JRS::Error;
use JRS::StrNumUtils;
use JRS::DateTimeUtils;

my $pt_db_source       = Config::get_value_for("database_host");
my $pt_db_catalog      = Config::get_value_for("database_name");
my $pt_db_user_id      = Config::get_value_for("database_username");
my $pt_db_password     = Config::get_value_for("database_password");

my %parula_h                    = Utils::get_user_settings();

my $dbtable_messages   = "ttchat_messages";

my $remote_ipaddress = $ENV{REMOTE_ADDR};


sub post_chat_message {

# use this here if want write and READ to be seen only by logged in users
#     if ( !_allowed_to_post() ) {
#         Error::report_error("400", "Invalid access.", "You need to login.");
#     } 

#    Error::report_error("400", "debug", "hey");

    my $q = new CGI;

    # my $request_method = $q->request_method();
    my $message_text = $q->param("message");
    my $sb           = $q->param("sb");

    if ( $sb ne "Get" ) {

        if ( !_allowed_to_post() ) {
            Error::report_error("400", "Invalid access.", "You need to login.");
        } 

        $message_text = StrNumUtils::trim_spaces($message_text);

        $message_text = Encode::decode_utf8($message_text);

        ## $message_text = HTML::Entities::decode($message_text);
        ## $message_text = URI::Escape::uri_unescape($message_text);

        my $err_msg;

        my $user_age_to_create_microblog = Config::get_value_for("min_user_age_create_comment"); 
        if ( !Data::been_member_long_enough($parula_h{userid}, $user_age_to_create_microblog) ) {
           $err_msg .= "You have not been a member long enough to post.";
        }

        if ( !defined($message_text) || length($message_text) < 1 )  { 
           $err_msg .= "You must enter text.";
        } 

        if ( length($message_text) > 300 ) {
            my $len = length($message_text);
            $err_msg .= "$len chars entered. Max is 300.";
        }

        if ( defined($err_msg) ) {
            my %hash;
            $hash{error_code}      = 1;
            $hash{status}          = 400;
            $hash{error_message}   = $err_msg;
            $hash{message_text}    = $message_text;
            my $json_str = encode_json \%hash;
            #  print header('application/json', '400 Accepted');
            print header('application/json', '200 Accepted');
            print $json_str;
            exit;
        } 

        my $message_id = _add_message($parula_h{userid}, $parula_h{username}, $message_text, $remote_ipaddress);
    }


    my @messages = _get_messages();

    @messages = _format_message_stream(\@messages);

    my %json_hash;
    $json_hash{messages} = \@messages;
    $json_hash{error_code} = 0;
    $json_hash{status}     = 200;

    my $json_str = encode_json \%json_hash;
    print header('application/json', '200 Accepted');
    print $json_str;

    exit;

}


sub _add_message {
    my $author_id          = shift;
    my $author_name        = shift; 
    my $message_text       = shift;
    my $remote_ipaddress   = shift;

    my $message_status = "o";

    my $date_time = Utils::create_datetime_stamp();

    my $db = Db->new($pt_db_catalog, $pt_db_user_id, $pt_db_password);
    Error::report_error("500", "Error connecting to database.", $db->errstr) if $db->err;

    $author_name      = $db->quote($author_name);
    $message_text     = $db->quote($message_text);
    $remote_ipaddress = $db->quote($remote_ipaddress);

    my $sql;
    $sql .= "insert into $dbtable_messages (message_text, message_status, author_id, author_name, created_date, ip_address)";
    $sql .= " values ($message_text, '$message_status', $author_id, $author_name, '$date_time', $remote_ipaddress)";
    my $message_id = $db->execute($sql);
    Error::report_error("500", "Error executing SQL.", $db->errstr) if $db->err;

    $db->disconnect;
    Error::report_error("500", "Error disconnecting from database.", $db->errstr) if $db->err;

    return $message_id;
}


sub _get_messages {

    my $db = Db->new($pt_db_catalog, $pt_db_user_id, $pt_db_password);
    Error::report_error("500", "Error connecting to database.", $db->errstr) if $db->err;

    my $sql = <<EOSQL;
        select message_id, message_text, message_status, author_name, created_date as dbdate,
        date_format(date_add(created_date, interval 0 hour), '%b %d, %Y') as created_date, 
        unix_timestamp(created_date) as date_epoch_seconds
        from $dbtable_messages  
        where message_status='o'
        order by message_id desc limit 150
EOSQL

    my @loop_data = $db->gethashes($sql);
    Error::report_error("500", "Error executing SQL.", $db->errstr) if $db->err;

    $db->disconnect;
    Error::report_error("500", "Error disconnecting from database.", $db->errstr) if $db->err;

    return @loop_data;

}

sub _format_message_stream {
    my $loop_data         = shift;
    my @messages = ();
    foreach my $hash_ref ( @$loop_data ) {
        $hash_ref->{created_date}   = DateTimeUtils::format_creation_date($hash_ref->{created_date}, $hash_ref->{date_epoch_seconds});
        push(@messages, $hash_ref);
    }
    return @messages;
}


sub chat {
    Presentation::set_template_name("chat");
    Presentation::display_page("TT Chat");
}

sub _allowed_to_post {

    my $rc = 1;

    if ( $parula_h{userid} < 1 ) {
        $rc = 0;
    } 

    if ( !Data::valid_user(\%parula_h) ) {
        $rc = 0;
    } 

    if ( Utils::invalid_ip_address() ) {
        $rc = 0;
    }

    return $rc;
}


1;
