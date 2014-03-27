#! /usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use threads;
use threads::shared;
use Time::HiRes qw(usleep nanosleep gettimeofday);
use Data::Dumper;
use POSIX;

my ($thread_count, $stop, @threads, $started_at, @needles);

$stop = 0;
$thread_count=8;
$started_at = gettimeofday();

my ($key_len, $key_name, $key_pass, $key_email, @status, $keycount, $matchstring) :shared;

$key_len=2048;
$key_name='username';
$key_pass='password';
$key_email='e@ma.il';
$keycount=0;


@needles = (    '^FACE',
                '^C0FFEE',
                '^BAD',
                '^F00D',
                '^1CE',
                '^B17C435',
                '^A1FA',
                '^CE0',
                '^B00B5',
                '^CAFE',
                '^66');


$matchstring = join('|', @needles);

until ($stop) {
   # thread
   my $num = 0;

   for (my $tc=1; $tc<=$thread_count; $tc++){
        my $t = threads->new(\&keyThread, $tc);
        push (@threads, $t);
        print "Spawned $tc threads\n";
   }

   my $loopy = 0;

   until ($stop){
        for (my $tr=1; $tr<=$thread_count; $tr++){
                #print "Thread $tr status: @status[$tr]\n";
                if (@status[$tr] eq 'found'){
                        print "------ FOUND A KEY!!!!!!! ------\n\n\n";
                        exit();
                }
        }
		
        $loopy++;
        if ($loopy%10==0){
                print "Found $keycount keys so far, running for " . sprintf("%.1f",(gettimeofday()-$started_at))."s (Rate:" . sprintf("%.1f",$keycount/(gettimeofday()-$started_at)) ."/s)\n";
        }
        for ("1".."1000"){
                #dat entropy
                rand(10000000);
        }
        usleep(500000); 
   }
}


sub keyThread{

    my $number = shift;
    my $tid = threads->tid();
    print "Thread $tid started, using key_scratch $number for this key ID\n";


    #print "Matchstring: $matchstring\n";

    my $KEYRING_OPTS = "--no-default-keyring --secret-keyring ./foo$number.sec --keyring ./foo$number.pub" ;

  until ($stop){

    @status[$number]='running';

    # Generate a key
    my $quiet = `bash keybatchgen.sh $number $key_len $key_name $key_pass $key_email 2>&1`;

    $keycount++;


    # Get the key short ID
    my $short_id = `gpg $KEYRING_OPTS --list-secret-keys | grep 'sec ' | cut -d ' ' -f 4`;
    my $long_id = `gpg $KEYRING_OPTS --keyid-format LONG  --list-secret-keys | grep 'sec ' | cut -d ' ' -f 4`;

    # Cut the key_length part
    my $cut = $key_len . 'R\/';
    $short_id =~ s/$cut//;
    $long_id =~ s/$cut//;
    chomp $short_id;
    chomp $long_id;

    my @matches;
    # Print it
    print "Found S:$short_id, L:$long_id\n";

    # Only export if it match a pattern


    if (@matches = ($long_id =~ m/($matchstring)/o)){


        @status[$number]='found';

        print Dumper(@matches);
        print "Export $short_id\n";

        # Create the filename
        my $base_name = '0x' . $long_id;

        # export it
        `gpg $KEYRING_OPTS --output $base_name.pub.gpg --armor --export $short_id`;
        `gpg $KEYRING_OPTS --output $base_name.sec.gpg --armor --export-secret-key $short_id`;
        threads->exit();
    }
  }
}
