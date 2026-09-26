<?php

namespace App\Http\Controllers;

use App\Models\Medico;
use App\Models\Paciente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CitaController extends Controller
{
    public function create()
    {
        $pacientes = Paciente::where('estado', true)->orderBy('nombres')->get();
        $medicos = Medico::where('estado', true)->orderBy('nombres')->get();

        return view('citas.create', compact('pacientes', 'medicos'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'id_paciente' => 'required|integer|exists:paciente,id_paciente',
            'id_medico' => 'required|integer|exists:medico,id_medico',
            'fecha' => 'required|date|after_or_equal:today',
            'hora_inicio' => 'required|date_format:H:i',
            'hora_fin' => 'required|date_format:H:i|after:hora_inicio',
            'motivo' => 'nullable|string|max:200',
        ]);

        try {
            // Se delega la validación de solapamiento al procedimiento
            // almacenado sp_agendar_cita, que ya la implementa mediante un
            // trigger en la base de datos (regla de negocio RN01).
            // Se usa DB::select() (no DB::statement()) porque el
            // procedimiento termina con un SELECT LAST_INSERT_ID().
            DB::select('CALL sp_agendar_cita(?, ?, ?, ?, ?, ?)', [
                $data['id_paciente'],
                $data['id_medico'],
                $data['fecha'],
                $data['hora_inicio'].':00',
                $data['hora_fin'].':00',
                $data['motivo'] ?? null,
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            // El trigger de la base de datos lanza un error controlado
            // (SIGNAL SQLSTATE) cuando detecta un horario solapado.
            return back()
                ->withInput()
                ->withErrors(['solapamiento' => 'Ese médico ya tiene una cita agendada en ese horario. Elige otro horario.']);
        }

        return redirect('/citas')->with('status', 'Cita agendada correctamente.');
    }

    public function index()
    {
        // vw_agenda_medica ya combina cita + paciente + médico en una sola
        // vista SQL, lista para mostrarse sin tener que armar el JOIN aquí.
        $citas = DB::table('vw_agenda_medica')
            ->orderBy('fecha_cita')
            ->orderBy('hora_inicio')
            ->get();

        return view('citas.index', compact('citas'));
    }
}
