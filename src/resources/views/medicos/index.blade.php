@extends('layouts.app')
@section('titulo', 'Médicos - Clínica Digital')
@section('encabezado', 'Médicos')
@section('subtitulo', 'Gestión de los médicos de la clínica (solo Administrador)')

@section('contenido')
<div class="panel">
    <div class="panel-header">
        <h2>Médicos registrados</h2>
        <a href="/medicos/crear" class="btn btn-primary">+ Registrar médico</a>
    </div>
    <table>
        <thead>
            <tr><th>Nombre</th><th>Especialidad</th><th>Colegiado</th><th>Teléfono</th><th>Correo</th><th>Estado</th><th></th></tr>
        </thead>
        <tbody>
            @forelse ($medicos as $m)
                <tr>
                    <td>{{ $m->nombres }} {{ $m->apellidos }}</td>
                    <td>{{ $m->especialidad }}</td>
                    <td>{{ $m->colegiado }}</td>
                    <td>{{ $m->telefono }}</td>
                    <td>{{ $m->correo }}</td>
                    <td><span class="estado {{ $m->estado ? 'activo' : 'inactivo' }}">{{ $m->estado ? 'Activo' : 'Inactivo' }}</span></td>
                    <td>
                        <form method="POST" action="/medicos/{{ $m->id_medico }}/estado" onsubmit="return confirm('¿Cambiar el estado de este médico?')">
                            @csrf
                            <button type="submit" class="btn btn-sm {{ $m->estado ? 'btn-danger' : 'btn-primary' }}">{{ $m->estado ? 'Desactivar' : 'Activar' }}</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr><td colspan="7">Aún no hay médicos registrados.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
