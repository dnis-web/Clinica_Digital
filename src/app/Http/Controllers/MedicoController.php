<?php

namespace App\Http\Controllers;

use App\Models\Medico;
use App\Models\Usuario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class MedicoController extends Controller
{
    // Rol "Médico" según la tabla rol (1 Administrador, 2 Recepción, 3 Médico, 4 Paciente).
    private const ROL_MEDICO = 3;

    public function index()
    {
        $medicos = Medico::orderBy('apellidos')->orderBy('nombres')->get();

        return view('medicos.index', compact('medicos'));
    }

    public function create()
    {
        return view('medicos.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombres' => 'required|string|max:100',
            'apellidos' => 'required|string|max:100',
            'colegiado' => 'required|string|max:20|unique:medico,colegiado',
            'especialidad' => 'required|string|max:100',
            'telefono' => 'nullable|string|max:15',
            'correo' => 'required|email|max:100|unique:usuario,correo|unique:medico,correo',
            // Política de contraseñas: mínimo 10 caracteres, con letras y números.
            'password' => ['required', 'confirmed', Password::min(10)->letters()->numbers()],
        ]);

        // El médico y su usuario de acceso se crean juntos: si algo falla,
        // no queda un registro a medias (transacción).
        DB::transaction(function () use ($data) {
            $usuario = Usuario::create([
                'id_clinica' => 1,
                'nombre' => $data['nombres'],
                'apellido' => $data['apellidos'],
                'correo' => $data['correo'],
                'password_hash' => Hash::make($data['password']),
                'estado' => true,
                'id_rol' => self::ROL_MEDICO,
            ]);

            Medico::create([
                'id_clinica' => 1,
                'id_usuario' => $usuario->id_usuario,
                'nombres' => $data['nombres'],
                'apellidos' => $data['apellidos'],
                'colegiado' => $data['colegiado'],
                'especialidad' => $data['especialidad'],
                'telefono' => $data['telefono'] ?? null,
                'correo' => $data['correo'],
                'estado' => true,
            ]);
        });

        return redirect('/medicos')->with('status', "Médico {$data['nombres']} {$data['apellidos']} registrado correctamente.");
    }

    public function cambiarEstado($id)
    {
        $medico = Medico::findOrFail($id);
        $nuevo = ! $medico->estado;

        // Al desactivar al médico también se desactiva su usuario (no podrá iniciar sesión).
        DB::transaction(function () use ($medico, $nuevo) {
            $medico->update(['estado' => $nuevo]);
            Usuario::where('id_usuario', $medico->id_usuario)->update(['estado' => $nuevo]);
        });

        return redirect('/medicos')->with('status', 'Médico '.($nuevo ? 'activado' : 'desactivado').' correctamente.');
    }
}
