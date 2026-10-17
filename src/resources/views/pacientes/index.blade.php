@extends('layouts.app')
@section('titulo', 'Pacientes - Clínica Digital')
@section('encabezado', 'Pacientes y expedientes')
@section('subtitulo', 'Busca un paciente para ver su ficha y su expediente clínico')

@section('contenido')
<div class="panel">
    <div class="panel-header">
        <form method="GET" action="/pacientes" style="display:flex;gap:10px;flex-wrap:wrap">
            <input type="text" name="q" value="{{ $q }}" placeholder="Buscar por nombre o DPI" maxlength="100"
                   style="padding:10px 12px;border:1px solid #ddd;border-radius:8px;min-width:260px">
            <button type="submit" class="btn btn-secondary">Buscar</button>
            @if ($q !== '')
                <a href="/pacientes" class="btn btn-secondary">Limpiar</a>
            @endif
        </form>
        <a href="/pacientes/crear" class="btn btn-primary">+ Registrar paciente</a>
    </div>

    <table>
        <thead>
            <tr><th>Paciente</th><th>DPI</th><th>Teléfono</th><th>Estado</th><th></th></tr>
        </thead>
        <tbody>
            @forelse ($pacientes as $p)
                <tr>
                    <td>{{ $p->nombres }} {{ $p->apellidos }}</td>
                    <td>{{ $p->dpi }}</td>
                    <td>{{ $p->telefono }}</td>
                    <td><span class="estado {{ $p->estado ? 'activo' : 'inactivo' }}">{{ $p->estado ? 'Activo' : 'Inactivo' }}</span></td>
                    <td><a href="/pacientes/{{ $p->id_paciente }}" class="btn btn-sm btn-primary">Ver ficha</a></td>
                </tr>
            @empty
                <tr><td colspan="5">No se encontraron pacientes.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
