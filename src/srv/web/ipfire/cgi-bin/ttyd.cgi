#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use HTML::Entities qw(encode_entities);

require "/var/ipfire/general-functions.pl";
require "${General::swroot}/header.pl";

my $config_file = "/etc/sysconfig/ttyd";
my %config = (
	TTYD_PORT      => "7681",
	TTYD_SSH_USER  => "root",
	TTYD_SSH_HOST  => "127.0.0.1",
	TTYD_SSH_PORT  => "22",
);

if (open(my $fh, "<", $config_file)) {
	while (my $line = <$fh>) {
		chomp $line;
		next if $line =~ /^\s*(?:#|$)/;
		if ($line =~ /^\s*([A-Za-z0-9_]+)\s*=\s*"?([^"]*)"?\s*$/) {
			$config{$1} = $2;
		}
	}
	close($fh);
}

sub service_running {
	return 0 unless -r "/run/ttyd.pid";
	open(my $fh, "<", "/run/ttyd.pid") or return 0;
	my $pid = <$fh>;
	close($fh);
	chomp $pid if defined $pid;
	return 0 unless defined $pid && $pid =~ /^\d+$/;
	return -d "/proc/$pid";
}

sub ttyd_tr {
	my ($key, $fallback) = @_;

	if (exists $Lang::tr{$key} && defined $Lang::tr{$key} && $Lang::tr{$key} ne "") {
		return $Lang::tr{$key};
	}

	my %zh = (
		'ttyd url'         => '链接地址',
		'ttyd target'      => 'SSH 目标',
		'ttyd status'      => '服务状态',
		'ttyd running'     => '运行中',
		'ttyd stopped'     => '已停止',
		'ttyd not running' => 'ttyd 未运行。请确认 ttyd 已安装、SSH 已启用，并且 IPFire WebUI 证书可用。',
	);

	my %tw = (
		'ttyd url'         => '連結地址',
		'ttyd target'      => 'SSH 目標',
		'ttyd status'      => '服務狀態',
		'ttyd running'     => '執行中',
		'ttyd stopped'     => '已停止',
		'ttyd not running' => 'ttyd 未執行。請確認 ttyd 已安裝、SSH 已啟用，並且 IPFire WebUI 憑證可用。',
	);

	if (($Lang::language || "") eq "tw" && exists $tw{$key}) {
		return $tw{$key};
	}

	if (($Lang::language || "") eq "zh" && exists $zh{$key}) {
		return $zh{$key};
	}

	return $fallback;
}

my $running = service_running();

my $host = $ENV{'HTTP_HOST'} || $ENV{'SERVER_NAME'} || $ENV{'SERVER_ADDR'} || "";
$host =~ s/:\d+$//;
my $url = "https://" . $host . ":" . ($config{TTYD_PORT} || "7681") . "/";
my $target = ($config{TTYD_SSH_USER} || "root") . "\@" . ($config{TTYD_SSH_HOST} || "127.0.0.1") . ":" . ($config{TTYD_SSH_PORT} || "22");

&Header::showhttpheaders();
&Header::openpage("ttyd", 1, "");
&Header::openbigbox("100%", "left");

print <<'STYLE';
<style>
.ttyd-meta {
	width: 100%;
	border-collapse: collapse;
	margin-bottom: 14px;
}
.ttyd-meta td {
	border-top: 1px solid #d6d6d6;
	padding: 8px 10px;
}
.ttyd-meta td:first-child {
	width: 170px;
	font-weight: bold;
}
.ttyd-terminal {
	width: 100%;
	height: 63vh;
	min-height: 600px;
	border: 1px solid #222;
	background: #111;
}
.ttyd-warning {
	border: 1px solid #d6a600;
	background: #fff7d7;
	padding: 10px;
}
</style>
STYLE

print "<table class='ttyd-meta'>\n";
print "<tr><td>" . encode_entities(ttyd_tr("ttyd url", "Link URL")) . "</td><td><a href='" . encode_entities($url) . "' target='_blank'>" . encode_entities($url) . "</a></td></tr>\n";
print "<tr><td>" . encode_entities(ttyd_tr("ttyd target", "SSH target")) . "</td><td>" . encode_entities($target) . "</td></tr>\n";
print "<tr><td>" . encode_entities(ttyd_tr("ttyd status", "Service status")) . "</td><td>" . encode_entities($running ? ttyd_tr("ttyd running", "running") : ttyd_tr("ttyd stopped", "stopped")) . "</td></tr>\n";
print "</table>\n";

if ($running) {
	print "<iframe class='ttyd-terminal' src='" . encode_entities($url) . "'></iframe>\n";
} else {
	print "<div class='ttyd-warning'>" . ttyd_tr("ttyd not running", "The terminal service is not running. Make sure ttyd is installed, SSH is enabled, and the IPFire WebUI certificate is available.") . "</div>\n";
}

&Header::closebigbox();
&Header::closepage();
