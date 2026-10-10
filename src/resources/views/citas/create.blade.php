@extends('layouts.app')
@section('titulo', 'Agendar cita - Clínica Digital')
@section('encabezado', 'Agendar cita')
@section('subtitulo', 'Citas de 30 minutos, de 8:00 AM a 4:00 PM. El sistema rechaza horarios ya ocupados por el médico')

@section('contenido')
<div class="panel">
    <form method="POST" action="/citas">
        @csrf
        <div class="form-grid">
            <div class="form-group">
                <label for="id_paciente">Paciente</label>
                <select id="id_paciente" name="id_paciente" required>
                    <option value="">-- Selecciona --</option>
                    @foreach ($pacientes as $p)
                        <option value="{{ $p->id_paciente }}" @selected(old('id_paciente') == $p->id_paciente)>{{ $p->nombres }} {{ $p->apellidos }} (DPI {{ $p->dpi }})</option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label for="id_medico">Médico</label>
                <select id="id_medico" name="id_medico" required>
                    <option value="">-- Selecciona --</option>
                    @foreach ($medicos as $m)
                        <option value="{{ $m->id_medico }}" @selected(old('id_medico') == $m->id_medico)>{{ $m->nombres }} {{ $m->apellidos }} — {{ $m->especialidad }}</option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label for="fecha">Fecha</label>
                <input id="fecha" type="date" name="fecha" value="{{ old('fecha') }}" required>
            </div>
            <div class="form-group">
                <label for="hora_inicio">Hora de la cita (30 min)</label>
                <select id="hora_inicio" name="hora_inicio" required>
                    <option value="">-- Selecciona --</option>
                    @foreach ($horarios as $h)
                        <option value="{{ $h }}" @selected(old('hora_inicio') == $h)>{{ \Carbon\Carbon::createFromFormat('H:i', $h)->format('g:i A') }}</option>
                    @endforeach
                </select>
            </div>
            <div class="form-group full">
                <label for="motivo">Motivo de la consulta</label>
                <input id="motivo" type="text" name="motivo" value="{{ old('motivo') }}" maxlength="200">
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Agendar cita</button>
        <a href="/citas" class="btn btn-secondary">Cancelar</a>
    </form>
</div>
@endsection
