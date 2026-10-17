@extends('layouts.app')
@section('titulo', 'Ficha del paciente - Clínica Digital')
@section('encabezado', $paciente->nombres.' '.$paciente->apellidos)
@section('subtitulo', 'Ficha del paciente y expediente clínico')

@section('contenido')
<div class="panel">
    <div class="panel-header">
        <h2>Datos del paciente</h2>
        <a href="/pacientes" class="btn btn-secondary">← Volver a pacientes</a>
    </div>
    <div class="form-grid">
        <p><strong>DPI:</strong> {{ $paciente->dpi }}</p>
        <p><strong>Fecha de nacimiento:</strong> {{ \Carbon\Carbon::parse($paciente->fecha_nacimiento)->format('d/m/Y') }}
            ({{ \Carbon\Carbon::parse($paciente->fecha_nacimiento)->age }} años)</p>
        <p><strong>Sexo:</strong> {{ $paciente->sexo === 'M' ? 'Masculino' : ($paciente->sexo === 'F' ? 'Femenino' : $paciente->sexo) }}</p>
        <p><strong>Teléfono:</strong> {{ $paciente->telefono ?: '—' }}</p>
        <p><strong>Correo:</strong> {{ $paciente->correo ?: '—' }}</p>
        <p><strong>Dirección:</strong> {{ $paciente->direccion ?: '—' }}</p>
        <p><strong>Expediente:</strong>
            @if ($expediente)
                abierto el {{ \Carbon\Carbon::parse($expediente->fecha_apertura)->format('d/m/Y') }}
                · <span class="estado {{ $expediente->estado ? 'activo' : 'inactivo' }}">{{ $expediente->estado ? 'Activo' : 'Inactivo' }}</span>
            @else
                sin expediente
            @endif
        </p>
    </div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Citas del paciente</h2>
        <a href="/citas/crear" class="btn btn-primary">+ Agendar cita</a>
    </div>
    <table>
        <thead>
            <tr><th>Fecha</th><th>Hora</th><th>Médico</th><th>Motivo</th><th>Estado</th><th></th></tr>
        </thead>
        <tbody>
            @forelse ($citas as $c)
                <tr>
                    <td>{{ \Carbon\Carbon::parse($c->fecha_cita)->format('d/m/Y') }}</td>
                    <td>{{ \Carbon\Carbon::parse($c->hora_inicio)->format('g:i A') }}</td>
                    <td>{{ $c->medico }}</td>
                    <td>{{ $c->motivo_consulta }}</td>
                    <td><span class="estado {{ strtolower($c->estado_cita) }}">{{ $c->estado_cita }}</span></td>
                    <td style="white-space:nowrap">
                        @if ($c->estado_cita === 'Programada')
                            @if ($esClinico)
                                <a href="/citas/{{ $c->id_cita }}/consulta" class="btn btn-sm btn-primary">Registrar consulta</a>
                            @endif
                            <form method="POST" action="/citas/{{ $c->id_cita }}/cancelar" style="display:inline"
                                  onsubmit="return confirm('¿Cancelar esta cita?')">
                                @csrf
                                <button type="submit" class="btn btn-sm btn-danger">Cancelar</button>
                            </form>
                        @endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="6">Este paciente aún no tiene citas.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="panel">
    <h2>Historial clínico</h2>
    @if (! $esClinico)
        <p>Información clínica restringida. Solo el personal médico y el administrador pueden ver el historial.</p>
    @else
        @forelse ($historial as $h)
            <div style="border-top:1px solid #eee;padding:14px 0">
                <p><strong>{{ \Carbon\Carbon::parse($h->fecha_consulta)->format('d/m/Y g:i A') }}</strong>
                    · {{ $h->medico }} ({{ $h->especialidad }})</p>
                <p><strong>Diagnóstico:</strong> {!! nl2br(e($h->diagnostico)) !!}</p>
                @if ($h->tratamiento)
                    <p><strong>Tratamiento:</strong> {!! nl2br(e($h->tratamiento)) !!}</p>
                @endif
                @if ($h->observaciones)
                    <p><strong>Observaciones:</strong> {!! nl2br(e($h->observaciones)) !!}</p>
                @endif
            </div>
        @empty
            <p>Aún no hay consultas registradas en este expediente.</p>
        @endforelse
    @endif
</div>
@endsection
