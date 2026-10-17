<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRol
{
    /**
     * Control de acceso por rol (RBAC). Se usa después de "checkauth":
     *   Route::middleware(['checkauth', 'checkrol:Administrador'])
     * Si el rol de la sesión no está entre los permitidos, responde 403.
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (! in_array(session('usuario_rol'), $roles, true)) {
            abort(403, 'No tienes permiso para acceder a esta sección.');
        }

        return $next($request);
    }
}
