#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

use Test::Simple tests => 15;

use Expect;

# If you want to see stdout, during
# tests for debugging, you can comment this out.
#$Expect::Log_Stdout = 0;

my $TO = 10;
my ($good, $text);

system(qq{make});

my $tty = Expect->spawn(qq{timeout -k 60 55 make qemu});
$tty->expect($TO, "init: starting sh");
sleep(1);

# Existing Shell Functionality
$tty->send("echo Hell world\n");
$tty->expect(5, "test complete: or2");
$tty->send("ls\n");
$tty->expect(5, "test complete: or2");
$tty->send("sh test1.sh\n");
$tty->expect(5, "test complete: or2");
$tty->send("sh test2.sh\n");
$tty->expect(5, "test complete: or2");
$tty->send("his\n");
$tty->expect(5, "test complete: or2");
$tty->send("his\n");
$tty->expect(5, "test complete: or2");

$tty->send("halt\n");
sleep(1);
