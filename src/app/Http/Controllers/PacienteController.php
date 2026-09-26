<?php

namespace App\Http\Controllers;

use App\Models\Paciente;
use Illuminate\Http\Request;

class PacienteController extends Controller
{
    public function create()
    {
        return view('pacientes.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'dpi' => 'required|string|max:20|unique:paciente,dpi',
            'nombres' => 'required|string|max:100',
            'apellidos' => 'required|string|max:100',
            'fecha_nacimiento' => 'required|date|before:today',
            'telefono' => 'nullable|string|max:15',
            'correo' => 'nullable|email|max:100',
            'direccion' => 'nullable|string|max:150',
            'sexo' => 'required|in:M,F',
        ]);

        // id_clinica fijo a 1 en este MVP (una sola clínica); en un escenario
        // multi-clínica real vendría de la sesión del usuario autenticado.
        $data['id_clinica'] = 1;
        $data['estado'] = true;

        // El trigger trg_paciente_after_insert (ya definido en la base de
        // datos) crea automáticamente el expediente clínico del paciente.
        $paciente = Paciente::create($data);

        return redirect('/citas/crear')
            ->with('status', "Paciente {$paciente->nombres} registrado correctamente.");
    }
}
