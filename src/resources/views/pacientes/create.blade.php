@extends('layouts.app')
@section('titulo', 'Registrar paciente - Clínica Digital')
@section('encabezado', 'Registrar paciente')
@section('subtitulo', 'Al registrar, el sistema crea automáticamente su expediente clínico')

@section('contenido')
<div class="panel">
    <form method="POST" action="/pacientes">
        @csrf
        <div class="form-grid">
            <div class="form-group">
                <label for="dpi">DPI</label>
                <input id="dpi" type="text" name="dpi" value="{{ old('dpi') }}" maxlength="20" required>
            </div>
            <div class="form-group">
                <label for="fecha_nacimiento">Fecha de nacimiento</label>
                <input id="fecha_nacimiento" type="date" name="fecha_nacimiento" value="{{ old('fecha_nacimiento') }}" required>
            </div>
            <div class="form-group">
                <label for="nombres">Nombres</label>
                <input id="nombres" type="text" name="nombres" value="{{ old('nombres') }}" maxlength="100" required>
            </div>
            <div class="form-group">
                <label for="apellidos">Apellidos</label>
                <input id="apellidos" type="text" name="apellidos" value="{{ old('apellidos') }}" maxlength="100" required>
            </div>
            <div class="form-group">
                <label for="sexo">Sexo</label>
                <select id="sexo" name="sexo" required>
                    <option value="">-- Selecciona --</option>
                    <option value="M" @selected(old('sexo') == 'M')>Masculino</option>
                    <option value="F" @selected(old('sexo') == 'F')>Femenino</option>
                </select>
            </div>
            <div class="form-group">
                <label for="telefono">Teléfono</label>
                <input id="telefono" type="text" name="telefono" value="{{ old('telefono') }}" maxlength="15">
            </div>
            <div class="form-group">
                <label for="correo">Correo electrónico</label>
                <input id="correo" type="email" name="correo" value="{{ old('correo') }}" maxlength="100">
            </div>
            <div class="form-group">
                <label for="direccion">Dirección</label>
                <input id="direccion" type="text" name="direccion" value="{{ old('direccion') }}" maxlength="150">
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Registrar paciente</button>
        <a href="/citas" class="btn btn-secondary">Cancelar</a>
    </form>
</div>
@endsection
