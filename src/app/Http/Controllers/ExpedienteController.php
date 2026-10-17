<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExpedienteController extends Controller
{
    // Roles que pueden ver y registrar información clínica.
    // Recepción solo ve datos básicos del paciente y la agenda.
    private const ROLES_CLINICOS = ['Administrador', 'Médico'];

    private function esClinico(): bool
    {
        return in_array(session('usuario_rol'), self::ROLES_CLINICOS, true);
    }

    /**
     * Un usuario con rol Médico solo puede actuar sobre SUS citas.
     * El Administrador y Recepción no tienen esta restricción.
     */
    private function validarPropiedadCita(object $cita): void
    {
        if (session('usuario_rol') !== 'Médico') {
            return;
        }

        $medico = DB::table('medico')->where('id_usuario', session('usuario_id'))->first();

        if (! $medico || (int) $medico->id_medico !== (int) $cita->id_medico) {
            abort(403, 'Solo puedes gestionar tus propias citas.');
        }
    }

    public function index(Request $request)
    {
        $q = trim((string) $request->query('q', ''));

        $pacientes = DB::table('paciente')
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($w) use ($q) {
                    $w->where('nombres', 'like', "%{$q}%")
                        ->orWhere('apellidos', 'like', "%{$q}%")
                        ->orWhere('dpi', 'like', "%{$q}%");
                });
            })
            ->orderBy('apellidos')
            ->orderBy('nombres')
            ->limit(100)
            ->get();

        return view('pacientes.index', compact('pacientes', 'q'));
    }

    public function show($id)
    {
        $paciente = DB::table('paciente')->where('id_paciente', $id)->first();
        abort_if(! $paciente, 404);

        $expediente = DB::table('expediente_clinico')->where('id_paciente', $id)->first();

        $citas = DB::table('vw_agenda_medica')
            ->where('id_paciente', $id)
            ->orderByDesc('fecha_cita')
            ->orderByDesc('hora_inicio')
            ->get();

        $esClinico = $this->esClinico();

        // El historial clínico solo se consulta si el rol tiene permiso.
        $historial = $esClinico
            ? DB::table('vw_historial_clinico')
                ->where('id_paciente', $id)
                ->whereNotNull('id_consulta')
                ->orderByDesc('fecha_consulta')
                ->get()
            : collect();

        return view('pacientes.show', compact('paciente', 'expediente', 'citas', 'historial', 'esClinico'));
    }

    public function consultaCreate($id)
    {
        $cita = DB::table('vw_agenda_medica')->where('id_cita', $id)->first();
        abort_if(! $cita, 404);
        $this->validarPropiedadCita($cita);

        if ($cita->estado_cita !== 'Programada') {
            return redirect('/pacientes/'.$cita->id_paciente)
                ->withErrors(['consulta' => 'Solo se puede registrar la consulta de una cita en estado Programada.']);
        }

        return view('consultas.create', compact('cita'));
    }

    public function consultaStore(Request $request, $id)
    {
        $data = $request->validate([
            'diagnostico' => 'required|string|max:5000',
            'tratamiento' => 'nullable|string|max:5000',
            'observaciones' => 'nullable|string|max:5000',
        ]);

        $cita = DB::table('cita')->where('id_cita', $id)->first();
        abort_if(! $cita, 404);
        $this->validarPropiedadCita($cita);

        if ($cita->estado_cita !== 'Programada') {
            return redirect('/pacientes/'.$cita->id_paciente)
                ->withErrors(['consulta' => 'Esa cita ya no está en estado Programada.']);
        }

        $expediente = DB::table('expediente_clinico')->where('id_paciente', $cita->id_paciente)->first();

        if (! $expediente) {
            return back()->withInput()->withErrors(['consulta' => 'El paciente no tiene expediente clínico.']);
        }

        // El trigger trg_consulta_marcar_atendida_ai marca la cita como
        // "Atendida" automáticamente al insertar la consulta.
        DB::table('consulta_medica')->insert([
            'id_expediente' => $expediente->id_expediente,
            'id_medico' => $cita->id_medico,
            'id_cita' => $cita->id_cita,
            'diagnostico' => $data['diagnostico'],
            'tratamiento' => $data['tratamiento'] ?? null,
            'observaciones' => $data['observaciones'] ?? null,
        ]);

        return redirect('/pacientes/'.$cita->id_paciente)->with('status', 'Consulta registrada en el expediente.');
    }

    public function cancelarCita($id)
    {
        $cita = DB::table('cita')->where('id_cita', $id)->first();
        abort_if(! $cita, 404);
        $this->validarPropiedadCita($cita);

        if ($cita->estado_cita !== 'Programada') {
            return redirect('/pacientes/'.$cita->id_paciente)
                ->withErrors(['consulta' => 'Solo se pueden cancelar citas en estado Programada.']);
        }

        try {
            DB::table('cita')->where('id_cita', $id)->update(['estado_cita' => 'Cancelada']);
        } catch (\Illuminate\Database\QueryException $e) {
            report($e);

            return redirect('/pacientes/'.$cita->id_paciente)
                ->withErrors(['consulta' => 'No se pudo cancelar la cita.']);
        }

        return redirect('/pacientes/'.$cita->id_paciente)->with('status', 'Cita cancelada.');
    }
}
