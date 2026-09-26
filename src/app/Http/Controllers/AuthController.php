<?php

namespace App\Http\Controllers;

use App\Models\Usuario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'correo' => 'required|email',
            'password' => 'required|string',
        ]);

        $usuario = Usuario::where('correo', $credentials['correo'])
            ->where('estado', true)
            ->first();

        $exitoso = $usuario && Hash::check($credentials['password'], $usuario->password_hash);

        // Registrar el intento en la bitácora de acceso (procedimiento ya
        // construido en la base de datos), tanto si fue exitoso como si no.
        try {
            DB::select('CALL sp_registrar_acceso(?, ?, ?, ?, ?)', [
                $usuario->id_usuario ?? null,
                $credentials['correo'],
                $request->ip(),
                $exitoso,
                $exitoso ? 'Inicio de sesión correcto' : 'Credenciales inválidas',
            ]);
        } catch (\Throwable $e) {
            // No bloquear el login si la bitácora falla; solo se registra en logs.
            report($e);
        }

        if (! $exitoso) {
            return back()->withErrors(['correo' => 'Correo o contraseña incorrectos.']);
        }

        session([
            'usuario_id' => $usuario->id_usuario,
            'usuario_nombre' => $usuario->nombre.' '.$usuario->apellido,
            'usuario_rol' => optional($usuario->rol)->nombre_rol,
        ]);

        return redirect('/citas')->with('status', 'Sesión iniciada correctamente.');
    }

    public function logout(Request $request)
    {
        $request->session()->flush();

        return redirect('/login')->with('status', 'Sesión cerrada.');
    }
}
