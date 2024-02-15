use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Tickit/Widget/Statusbar.pm',
    'lib/Tickit/Widget/Statusbar.pod',
    'lib/Tickit/Widget/Statusbar/CPU.pm',
    'lib/Tickit/Widget/Statusbar/CPU.pod',
    'lib/Tickit/Widget/Statusbar/Clock.pm',
    'lib/Tickit/Widget/Statusbar/Clock.pod',
    'lib/Tickit/Widget/Statusbar/Icon.pm',
    'lib/Tickit/Widget/Statusbar/Icon.pod',
    'lib/Tickit/Widget/Statusbar/Memory.pm',
    'lib/Tickit/Widget/Statusbar/Memory.pod',
    'lib/Tickit/Widget/Statusbar/WidgetList.pm',
    't/00-check-deps.t',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    'xt/author/distmeta.t',
    'xt/author/eol.t',
    'xt/author/minimum-version.t',
    'xt/author/mojibake.t',
    'xt/author/no-tabs.t',
    'xt/author/pod-syntax.t',
    'xt/author/portability.t',
    'xt/author/test-version.t',
    'xt/release/common_spelling.t',
    'xt/release/cpan-changes.t'
);

notabs_ok($_) foreach @files;
done_testing;
