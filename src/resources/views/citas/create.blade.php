@extends('layouts.app')
@section('titulo', 'Agendar cita - Clínica Digital')
@section('encabezado', 'Agendar cita')
@section('subtitulo', 'El sistema rechaza horarios que se traslapan con otra cita del mismo médico')

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
            <div class="form-group"></div>
            <div class="form-group">
                <label for="hora_inicio">Hora de inicio</label>
                <input id="hora_inicio" type="time" name="hora_inicio" value="{{ old('hora_inicio') }}" required>
            </div>
            <div class="form-group">
                <label for="hora_fin">Hora de fin</label>
                <input id="hora_fin" type="time" name="hora_fin" value="{{ old('hora_fin') }}" required>
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
