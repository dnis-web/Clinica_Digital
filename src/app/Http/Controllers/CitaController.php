<?php

namespace App\Http\Controllers;

use App\Models\Medico;
use App\Models\Paciente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class CitaController extends Controller
{
    // Citas de duración fija: horario de atención de 08:00 a 16:00,
    // en bloques de 30 minutos (la última cita inicia a las 15:30).
    private const DURACION_MIN = 30;

    private function horarios(): array
    {
        $bloques = [];
        for ($t = 8 * 60; $t < 16 * 60; $t += self::DURACION_MIN) {
            $bloques[] = sprintf('%02d:%02d', intdiv($t, 60), $t % 60);
        }

        return $bloques;
    }

    public function create()
    {
        $pacientes = Paciente::where('estado', true)->orderBy('nombres')->get();
        $medicos = Medico::where('estado', true)->orderBy('nombres')->get();

        $horarios = $this->horarios();

        return view('citas.create', compact('pacientes', 'medicos', 'horarios'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'id_paciente' => 'required|integer|exists:paciente,id_paciente',
            'id_medico' => 'required|integer|exists:medico,id_medico',
            'fecha' => 'required|date|after_or_equal:today',
            'hora_inicio' => ['required', Rule::in($this->horarios())],
            'motivo' => 'nullable|string|max:200',
        ]);

        // La hora de fin se calcula: toda cita dura 30 minutos.
        $inicio = \Carbon\Carbon::createFromFormat('H:i', $data['hora_inicio']);
        $horaFin = $inicio->copy()->addMinutes(self::DURACION_MIN)->format('H:i:s');

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
                $horaFin,
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
