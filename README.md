# Docker Base Image for Symfony

This uses environment variables to control the Symfony environment.  They MUST be set:

- `SYMFONY_ENV` : one of `prod`, `test` or `dev`
- `SYMFONY_DEBUG` : `1` or `0`, indicates whether Debug toolbar (and other Debug tools) are enabled/disabled.

The `app_dev.php` file should be removed and you should replace the `app.php` file with the following contents:

```php
use Symfony\Component\HttpFoundation\Request;

$loader = require __DIR__.'/../app/autoload.php';

$environment = getenv('SYMFONY_ENV');
$debug = (bool)getenv('SYMFONY_DEBUG');

if ($debug == true) {
    Symfony\Component\Debug\Debug::enable();
}

$app = new MicroKernel($environment, $debug);

$app->loadClassCache();

$request = Request::createFromGlobals();
$response = $app->handle($request);
$response->send();

$app->terminate($request, $response);
```
