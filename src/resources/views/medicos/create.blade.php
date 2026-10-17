@extends('layouts.app')
@section('titulo', 'Registrar médico - Clínica Digital')
@section('encabezado', 'Registrar médico')
@section('subtitulo', 'Se crea también su usuario de acceso con rol Médico')

@section('contenido')
<div class="panel">
    <form method="POST" action="/medicos">
        @csrf
        <div class="form-grid">
            <div class="form-group">
                <label for="nombres">Nombres</label>
                <input id="nombres" type="text" name="nombres" value="{{ old('nombres') }}" maxlength="100" required>
            </div>
            <div class="form-group">
                <label for="apellidos">Apellidos</label>
                <input id="apellidos" type="text" name="apellidos" value="{{ old('apellidos') }}" maxlength="100" required>
            </div>
            <div class="form-group">
                <label for="colegiado">Número de colegiado</label>
                <input id="colegiado" type="text" name="colegiado" value="{{ old('colegiado') }}" maxlength="20" required>
            </div>
            <div class="form-group">
                <label for="especialidad">Especialidad</label>
                <input id="especialidad" type="text" name="especialidad" value="{{ old('especialidad') }}" maxlength="100" required>
            </div>
            <div class="form-group">
                <label for="telefono">Teléfono</label>
                <input id="telefono" type="text" name="telefono" value="{{ old('telefono') }}" maxlength="15">
            </div>
            <div class="form-group">
                <label for="correo">Correo (será su usuario de acceso)</label>
                <input id="correo" type="email" name="correo" value="{{ old('correo') }}" maxlength="100" required>
            </div>
            <div class="form-group">
                <label for="password">Contraseña (mínimo 10 caracteres, con letras y números)</label>
                <input id="password" type="password" name="password" autocomplete="new-password" required>
            </div>
            <div class="form-group">
                <label for="password_confirmation">Confirmar contraseña</label>
                <input id="password_confirmation" type="password" name="password_confirmation" autocomplete="new-password" required>
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Registrar médico</button>
        <a href="/medicos" class="btn btn-secondary">Cancelar</a>
    </form>
</div>
@endsection
