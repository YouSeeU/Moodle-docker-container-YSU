<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = getenv('DATABASE_TYPE');
$CFG->dblibrary = 'native';
$CFG->dbhost    = getenv('MYSQL_HOST');
$CFG->dbname    = getenv('MYSQL_DATABASE_NAME');
$CFG->dbuser    = getenv('MYSQL_USER');
$CFG->dbpass    = getenv('MYSQL_PASSWORD');
$CFG->prefix    = 'mdl_';
$CFG->dboptions = [
    'dbpersist' => 0,
    'dbport' => getenv('MYSQL_PORT_NUMBER'),
    'dbsocket' => '',
    'dbcollation' => 'utf8mb4_unicode_ci',
];

$CFG->wwwroot   = getenv('MOODLE_URL');
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = getenv('MOODLE_USERNAME');

$CFG->directorypermissions = 02777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
