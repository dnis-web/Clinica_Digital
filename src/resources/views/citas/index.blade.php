@extends('layouts.app')
@section('titulo', 'Agenda de citas - Clínica Digital')
@section('encabezado', 'Agenda de citas')
@section('subtitulo', 'Citas programadas por fecha y hora')

@section('contenido')
<div class="panel">
    <div class="panel-header">
        <h2>Citas</h2>
        <a href="/citas/crear" class="btn btn-primary">+ Agendar cita</a>
    </div>
    <table>
        <thead>
            <tr><th>Fecha</th><th>Hora</th><th>Paciente</th><th>Médico</th><th>Estado</th></tr>
        </thead>
        <tbody>
            @forelse ($citas as $cita)
                <tr>
                    <td>{{ $cita->fecha_cita }}</td>
                    <td>{{ substr($cita->hora_inicio, 0, 5) }} - {{ substr($cita->hora_fin, 0, 5) }}</td>
                    <td>{{ $cita->paciente }}</td>
                    <td>{{ $cita->medico }}</td>
                    <td><span class="estado {{ strtolower($cita->estado_cita) }}">{{ $cita->estado_cita }}</span></td>
                </tr>
            @empty
                <tr><td colspan="5">Aún no hay citas agendadas.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
