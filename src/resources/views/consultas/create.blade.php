@extends('layouts.app')
@section('titulo', 'Registrar consulta - Clínica Digital')
@section('encabezado', 'Registrar consulta')
@section('subtitulo', 'Diagnóstico y tratamiento del paciente. Al guardar, la cita pasa a Atendida')

@section('contenido')
<div class="panel">
    <p><strong>Paciente:</strong> {{ $cita->paciente }}
       · <strong>Médico:</strong> {{ $cita->medico }}
       · <strong>Cita:</strong> {{ \Carbon\Carbon::parse($cita->fecha_cita)->format('d/m/Y') }}
       {{ \Carbon\Carbon::parse($cita->hora_inicio)->format('g:i A') }}</p>
    @if ($cita->motivo_consulta)
        <p><strong>Motivo:</strong> {{ $cita->motivo_consulta }}</p>
    @endif
</div>

<div class="panel">
    <form method="POST" action="/citas/{{ $cita->id_cita }}/consulta">
        @csrf
        <div class="form-grid">
            <div class="form-group full">
                <label for="diagnostico">Diagnóstico</label>
                <textarea id="diagnostico" name="diagnostico" rows="4" maxlength="5000" required>{{ old('diagnostico') }}</textarea>
            </div>
            <div class="form-group full">
                <label for="tratamiento">Tratamiento</label>
                <textarea id="tratamiento" name="tratamiento" rows="4" maxlength="5000">{{ old('tratamiento') }}</textarea>
            </div>
            <div class="form-group full">
                <label for="observaciones">Observaciones</label>
                <textarea id="observaciones" name="observaciones" rows="3" maxlength="5000">{{ old('observaciones') }}</textarea>
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Guardar consulta</button>
        <a href="/pacientes/{{ $cita->id_paciente }}" class="btn btn-secondary">Cancelar</a>
    </form>
</div>
@endsection
