<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckAuth
{
    /**
     * Verifica que exista una sesión de usuario activa (usuario_id en sesión)
     * antes de permitir el acceso a rutas protegidas como agendar citas
     * o registrar pacientes.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! session('usuario_id')) {
            return redirect('/login')->with('error', 'Debes iniciar sesión para continuar.');
        }

        return $next($request);
    }
}
