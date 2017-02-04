<?php

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Debug\Debug;

$loader = require __DIR__.'/../app/autoload.php';

$environment = getenv('SYMFONY_ENV');
$debug = (bool)getenv('SYMFONY_DEBUG');

if ($debug == true) {
    Debug::enable();
}

$app = new MicroKernel($environment, $debug);

$app->loadClassCache();

$request = Request::createFromGlobals();
$response = $app->handle($request);
$response->send();

$app->terminate($request, $response);
