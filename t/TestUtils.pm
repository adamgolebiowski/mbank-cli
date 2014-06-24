# Copyright © 2014 Jakub Wilk <jwilk@jwilk.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

package TestUtils;

use strict;
use warnings;

use v5.10;

use base qw(Exporter);

our @EXPORT = qw(
    check_ld
    code_dir
    code_file
    create_config
    test_dir
    test_file
    tmp_dir
);

use English qw(-no_match_vars);
use File::Temp ();

use IPC::Run ();

sub check_ld
{
    my ($stdout, $stderr);
    my $cli = IPC::Run::start(
        ['true'],
        '>', \$stdout,
        '2>', \$stderr,
    );
    $cli->finish();
    $cli->result == 0
        or die;
    $stdout eq ''
        or die;
    $stderr eq ''
        or die $stderr;
    return;
}

my $_tmp_dir = File::Temp::tempdir(
    template => 'mbank-cli.test.XXXXXX',
    TMPDIR => 1,
    CLEANUP => 1,
) or die;

sub tmp_dir
{
    return $_tmp_dir;
}

(my $_test_dir =  __FILE__ ) =~ s{/[^/]*\z}{};

sub test_dir
{
    return $_test_dir;
}

sub test_file
{
    my ($path) = @_;
    return "$_test_dir/$path";
}

sub code_dir
{
    return "$_test_dir/..";
}

sub code_file
{
    my ($path) = @_;
    $path //= 'mbank-cli';
    return "$_test_dir/../$path";
}

sub create_config
{
    my ($config) = @_;
    $config =~ s/<tmp>/$_tmp_dir/g;
    $config =~ s/<test>/$_test_dir/g;
    my $path = "$_tmp_dir/mbank-cli.conf";
    open(my $fh, '>', $path) or die $ERRNO;
    print {$fh} $config;
    close($fh) or die $ERRNO;
    return $path;
}


1;

# vim:ts=4 sw=4 et