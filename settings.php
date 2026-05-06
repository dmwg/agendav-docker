<?php
// Site title
$app['site.title'] = 'Welcome to Example Agendav Server';
// Site logo (should be placed in public/img). Optional
$app['site.logo'] = 'agendav_100transp.png';
// Site footer. Optional
$app['site.footer'] = 'Hosted by Example Company';

// Trusted proxy ips
$app['proxies'] = ['127.0.0.1'];
// Database settings
$app['db.options'] = [
    	'path' => '/var/agendav/db.sqlite',
    	'driver' => 'pdo_sqlite',
];
// Log path
$app['log.path'] = '/tmp';
// Base URL
$app['caldav.baseurl'] = 'https://cal.server.de/cal.php';
// Authentication method required by CalDAV server (basic or digest)
$app['caldav.authmethod'] = 'basic';
// Whether to show public CalDAV urls
$app['caldav.publicurls'] = true;
// Whether to show public CalDAV urls
$app['caldav.baseurl.public'] = 'https://cal.server.de/';
// Default timezone
$app['defaults.timezone'] = 'Europe/Berlin';
// Default languajge
$app['defaults.language'] = 'en';
// Default time format. Options: '12' / '24'
$app['defaults.time.format'] = '24';
/*
 * Default date format. Options:
 *
 * - ymd: YYYY-mm-dd
 * - dmy: dd-mm-YYYY
 * - mdy: mm-dd-YYYY
 */
$app['defaults.date_format'] = 'ymd';
// Default first day of week. Options: 0 (Sunday), 1 (Monday)
$app['defaults.weekstart'] = '1';
// Logout redirection. Optional
$app['logout.redirection'] = '';
// Calendar sharing
$app['calendar.sharing'] = true;
